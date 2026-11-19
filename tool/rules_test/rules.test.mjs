// Runs firestore.rules in the local Firestore emulator. `npm test` here.
// Covers the order money checks and the retailer stock write.
import { readFileSync } from 'node:fs';
import { after, before, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc, serverTimestamp } from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-jyoti',
    firestore: {
      rules: readFileSync(process.env.RULES_FILE ?? new URL('../../firestore.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users/r1'), { role: 'customer', status: 'approved' });
    await setDoc(doc(db, 'products/p1'), { name: 'Rice', price: 100, stock: 40 });
  });
});

after(() => env.cleanup());

const retailer = () => env.authenticatedContext('r1').firestore();
let n = 0;

// Same arithmetic the app does (OrderModel.toFirestore), so float results match.
function order({ subtotal, discount = null, couponCode = null, delivery = 120, grandTotal }) {
  return {
    userId: 'r1',
    subtotal,
    deliveryCharge: delivery,
    couponCode,
    discount,
    grandTotal: grandTotal ?? subtotal - (discount ?? 0) + delivery,
    orderStatus: 'pending',
    paymentStatus: 'pending',
    createdAt: serverTimestamp(),
  };
}
const place = (o) => setDoc(doc(retailer(), `orders/o${++n}`), o);

test('order without a coupon is allowed', () =>
  assertSucceeds(place(order({ subtotal: 3000 }))));

test('WELCOME10 at its ₹250 cap is allowed', () =>
  assertSucceeds(place(order({ subtotal: 3000, couponCode: 'WELCOME10', discount: 250 }))));

test('WELCOME10 above the cap is refused', () =>
  assertFails(place(order({ subtotal: 3000, couponCode: 'WELCOME10', discount: 300 }))));

test('FLAT5 with the app-computed fractional discount is allowed', () => {
  const subtotal = 7777.7;
  return assertSucceeds(
    place(order({ subtotal, couponCode: 'FLAT5', discount: (subtotal * 5) / 100 })),
  );
});

test('FLAT5 below its ₹5,000 minimum is refused', () =>
  assertFails(place(order({ subtotal: 4000, couponCode: 'FLAT5', discount: 200 }))));

test('an unknown coupon code is refused', () =>
  assertFails(place(order({ subtotal: 3000, couponCode: 'FREE100', discount: 100 }))));

test('a discount with no coupon code is refused', () =>
  assertFails(place(order({ subtotal: 3000, discount: 100 }))));

test('discount equal to the whole subtotal is refused', () =>
  assertFails(place(order({ subtotal: 3000, couponCode: 'WELCOME10', discount: 3000 }))));

test('a grand total lower than subtotal - discount + delivery is refused', () =>
  assertFails(place(order({ subtotal: 3000, grandTotal: 10 }))));

test('a negative delivery charge is refused', () =>
  assertFails(place(order({ subtotal: 3000, delivery: -500 }))));

test('below the ₹2,500 minimum is still refused', () =>
  assertFails(place(order({ subtotal: 2000 }))));

test('retailer may lower stock (placing an order)', () =>
  assertSucceeds(updateDoc(doc(retailer(), 'products/p1'), { stock: 38 })));

test('retailer may not set negative stock', () =>
  assertFails(updateDoc(doc(retailer(), 'products/p1'), { stock: -1 })));

test('retailer may not set stock to text', () =>
  assertFails(updateDoc(doc(retailer(), 'products/p1'), { stock: 'lots' })));

test('retailer may not change the price', () =>
  assertFails(updateDoc(doc(retailer(), 'products/p1'), { price: 1 })));
