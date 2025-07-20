import {onDocumentDeleted} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

admin.initializeApp();
const db = admin.firestore();

// This function triggers whenever a document in 'farm_locations' is deleted.
export const onlocationdelete = onDocumentDeleted(
  "farm_locations/{locationId}",
  async (event) => {
    // The event object contains all the context and data
    const deletedLocationId = event.params.locationId;
    logger.log(`Starting cascade delete for location: ${deletedLocationId}`);

    // This is a robust, iterative approach to find all descendants
    // without running into recursion limits.
    const locationsToDelete = new Set<string>();
    const queue = [deletedLocationId];

    while (queue.length > 0) {
      const parentId = queue.shift();
      if (!parentId) continue;

      // Find all immediate children of the current parentId
      const childrenSnapshot = await db
        .collection("farm_locations")
        .where("parentId", "==", parentId)
        .get();

      for (const doc of childrenSnapshot.docs) {
        // Add the child to the list of documents to be deleted
        locationsToDelete.add(doc.id);
        // Add the child to the queue to find its children in the next loop
        queue.push(doc.id);
      }
    }

    if (locationsToDelete.size === 0) {
      logger.log("No descendant locations to delete.");
      return;
    }

    logger.log(`Found ${locationsToDelete.size} descendants to delete.`);

    // Use a batched write to delete all descendants in one atomic operation.
    const batch = db.batch();
    locationsToDelete.forEach((docId) => {
      const docRef = db.collection("farm_locations").doc(docId);
      batch.delete(docRef);
    });

    await batch.commit();
    logger.log("Successfully deleted all descendant locations.");
    return;
  },
);
