const apiUrl = process.env.AFRIGO_API_URL?.replace(/\/$/, '');
const tokens = {
  buyer: process.env.AFRIGO_E2E_BUYER_TOKEN,
  supplier: process.env.AFRIGO_E2E_SUPPLIER_TOKEN,
  exporter: process.env.AFRIGO_E2E_EXPORTER_TOKEN,
};
if (!apiUrl || Object.values(tokens).some((value) => !value)) {
  throw new Error('AFRIGO_API_URL and all three AFRIGO_E2E_*_TOKEN values are required');
}

const uid = (token) => JSON.parse(Buffer.from(token.split('.')[1], 'base64url')).sub;
const ids = Object.fromEntries(Object.entries(tokens).map(([role, token]) => [role, uid(token)]));

async function call(role, path, options = {}) {
  const response = await fetch(`${apiUrl}${path}`, {
    ...options,
    headers: {
      authorization: `Bearer ${tokens[role]}`,
      'content-type': 'application/json',
      ...(options.headers || {}),
    },
    body: options.body ? JSON.stringify(options.body) : undefined,
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(`${role} ${path}: ${response.status} ${JSON.stringify(body)}`);
  return body.data || body;
}

const runId = `e2e-${Date.now()}`;
const participants = Object.values(ids);

const lot = await call('supplier', '/lots', { method: 'POST', body: {
  title: `Verified cocoa ${runId}`, quantity: 1000, price: 2500, currency: 'USD',
  participantIds: participants, status: 'active',
}});
const rfq = await call('buyer', '/rfqs', { method: 'POST', body: {
  title: `Cocoa RFQ ${runId}`, lotId: lot.id, quantity: 500,
  participantIds: participants, status: 'open',
}});
const offer = await call('supplier', '/offers', { method: 'POST', body: {
  rfqId: rfq.id, lotId: lot.id, amount: 1250000, currency: 'USD',
  participantIds: participants, status: 'submitted',
}});
const contract = await call('buyer', '/contracts', { method: 'POST', body: {
  rfqId: rfq.id, offerId: offer.id, participantIds: participants, status: 'signed',
}});
const order = await call('buyer', '/orders', { method: 'POST', body: {
  contractId: contract.id, buyerId: ids.buyer, supplierId: ids.supplier,
  totalAmount: 12500, currency: 'USD', participantIds: participants, status: 'confirmed',
}});
const inspection = await call('exporter', '/quality_inspections', { method: 'POST', body: {
  orderId: order.id, participantIds: participants, status: 'passed',
  items: [{ name: 'Moisture', status: 'pass' }],
}});
const shipment = await call('exporter', '/shipments', { method: 'POST', body: {
  orderId: order.id, inspectionId: inspection.id, participantIds: participants,
  status: 'in_transit', trackingNumber: `${runId}-TRACK`,
}});
const payment = await call('buyer', '/payments', { method: 'POST',
  headers: { 'idempotency-key': `${runId}-payment` }, body: { orderId: order.id },
});
await call('exporter', `/shipments/${shipment.id}`, {
  method: 'PATCH', body: { status: 'delivered', deliveredAt: new Date().toISOString() },
});
const [buyerOrder, supplierOffer, exporterShipment, analytics] = await Promise.all([
  call('buyer', `/orders/${order.id}`),
  call('supplier', `/offers/${offer.id}`),
  call('exporter', `/shipments/${shipment.id}`),
  call('buyer', '/analytics/market'),
]);
if (buyerOrder.id !== order.id || supplierOffer.id !== offer.id ||
    exporterShipment.status !== 'delivered' ||
    !(payment.flutterwavePaymentUrl || payment.clientSecret) || !analytics.calculatedAt) {
  throw new Error('Workflow verification returned inconsistent production state');
}
process.stdout.write(JSON.stringify({ ok: true, runId, lot: lot.id, rfq: rfq.id,
  offer: offer.id, contract: contract.id, order: order.id, inspection: inspection.id,
  shipment: shipment.id, payment: payment.id }, null, 2));
