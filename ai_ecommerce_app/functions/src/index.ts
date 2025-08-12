import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import stringSimilarity from 'string-similarity';

admin.initializeApp();
const db = admin.firestore();

export const recommendProducts = functions.https.onCall(async (data, context) => {
  const name: string = data?.name || '';
  const category: string = data?.category || '';
  if (!name) return { productIds: [] };

  const snapshot = await db.collection('products').get();
  const candidates: Array<{ id: string; name: string; category: string }> = snapshot.docs.map((d) => ({ id: d.id, name: d.get('name'), category: d.get('category') }));

  const names = candidates.map((c) => c.name);
  const scores = stringSimilarity.findBestMatch(name, names);

  const scored = candidates.map((c, idx) => {
    const base = scores.ratings[idx].rating; // 0..1
    const bonus = c.category?.toLowerCase() === category?.toLowerCase() ? 0.25 : 0;
    return { id: c.id, score: Math.min(1, base + bonus) };
  });

  scored.sort((a, b) => b.score - a.score);
  const top = scored.filter((s) => s.score > 0.2).slice(0, 10).map((s) => s.id);

  return { productIds: top };
});

export const onProductWriteSendOffer = functions.firestore.document('products/{productId}').onWrite(async (change, context) => {
  const after = change.after?.data();
  if (!after) return;
  const specialOffer = after['specialOffer'] === true;
  if (!specialOffer) return;
  const name = after['name'] || 'منتج';
  await admin.messaging().sendToTopic('offers', {
    notification: {
      title: 'عرض خاص',
      body: `${name} بانتظارك!`,
    },
    data: {
      productId: change.after.id,
    },
  });
});