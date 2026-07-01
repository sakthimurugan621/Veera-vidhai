/**
 * Veera Vidhai — Cloud Functions
 *
 * When a student marks attendance (a new document is created in the
 * `attendance` collection), notify every registered admin device with the
 * student's name and phone number. Works whether the admin app is open,
 * in background, or fully closed.
 */
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

/** Send a multicast message and prune stale tokens. */
async function sendToTokens(tokens, title, body, data) {
  if (!tokens || tokens.length === 0) return;
  const message = {
    notification: {title, body},
    android: {
      priority: "high",
      notification: {
        channelId: "attendance_channel",
        sound: "default",
        icon: "ic_launcher",
      },
    },
    apns: {payload: {aps: {sound: "default"}}},
    data: data || {},
    tokens,
  };
  const resp = await getMessaging().sendEachForMulticast(message);
  console.log(`Sent: ${resp.successCount}, Failed: ${resp.failureCount}`);
  const stale = [];
  resp.responses.forEach((r, i) => {
    if (!r.success) {
      const code = r.error && r.error.code;
      if (
        code === "messaging/invalid-registration-token" ||
        code === "messaging/registration-token-not-registered"
      ) {
        stale.push(tokens[i]);
      }
    }
  });
  if (stale.length) {
    const db = getFirestore();
    await Promise.all(
        stale.map((t) => db.collection("admin_tokens").doc(t).delete()),
    );
  }
}

async function getAdminTokens() {
  const snap = await getFirestore().collection("admin_tokens").get();
  return snap.docs.map((d) => d.id);
}

exports.onAttendanceCreated = onDocumentCreated(
    "attendance/{id}",
    async (event) => {
      const data = event.data && event.data.data();
      if (!data) return;

      // Only notify admins when a STUDENT self-reports absent.
      if (data.markedBy !== "student" || data.status !== "absent") return;

      const name = data.studentName || "A student";
      const roll = data.rollNo || "";

      const tokens = await getAdminTokens();
      await sendToTokens(
          tokens,
          "Student Absent 🔴",
          `${name} (Roll ${roll}) reported absent today`,
          {type: "attendance_absent", studentName: name, rollNo: roll},
      );
    },
);

/**
 * A student applied for leave → notify all admins.
 */
exports.onLeaveCreated = onDocumentCreated("leaves/{id}", async (event) => {
  const data = event.data && event.data.data();
  if (!data) return;

  const name = data.studentName || "A student";
  const roll = data.rollNo || "";
  const type = data.leaveType || "Leave";
  const from = data.fromDate || "";
  const to = data.toDate || "";
  const range = from ? (from === to ? ` (${from})` : ` (${from} → ${to})`) : "";

  const tokens = await getAdminTokens();
  await sendToTokens(
      tokens,
      "New Leave Request 📩",
      `${name} (Roll ${roll}) applied for ${type}${range}`,
      {type: "leave_request", studentName: name, rollNo: roll},
  );
});

/**
 * Admin approved / declined a leave → notify that student's devices.
 */
exports.onLeaveStatusChanged = onDocumentUpdated(
    "leaves/{id}",
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();
      if (!before || !after) return;
      if (before.status === after.status) return;
      if (after.status !== "approved" && after.status !== "declined") return;

      const studentId = after.studentId;
      if (!studentId) return;

      const studentDoc = await getFirestore()
          .collection("students")
          .doc(studentId)
          .get();
      const tokens = (studentDoc.data() || {}).fcmTokens || [];
      if (tokens.length === 0) return;

      const approved = after.status === "approved";
      await sendToTokens(
          tokens,
          approved ? "Leave Approved ✅" : "Leave Declined ❌",
          approved ?
            `Your ${after.leaveType} request has been approved.` :
            `Your ${after.leaveType} request has been declined.`,
          {type: "leave_status", status: after.status},
      );
    },
);
