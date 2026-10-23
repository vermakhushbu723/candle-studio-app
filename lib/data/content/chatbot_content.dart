/// Rule-based support bot "Diya" — same intents as the website (candle-studio/src/data/chatbot.js).
/// Action types: route (in-app screen), whatsapp, call, inquiry (opens the callback form → POST /tickets).
library;

enum BotActionType { route, whatsapp, call, inquiry }

class BotAction {
  const BotAction(this.type, this.label, {this.route, this.topic});
  final BotActionType type;
  final String label;
  final String? route;
  final String? topic;
}

class BotIntent {
  const BotIntent(this.id, this.pattern, this.text, {this.actions = const [], this.products = const []});
  final String id;
  final String pattern;
  final String text;
  final List<BotAction> actions;
  final List<String> products;

  bool matches(String message) => RegExp(pattern, caseSensitive: false).hasMatch(message);
}

const botGreeting = 'Hi! I’m Diya, your candle assistant. How can I help you today?';
const botQuickReplies = ['Track my order', 'Help me choose a candle', 'Bulk / corporate gifting', 'Shipping & COD', 'Returns & damage', 'Talk to a human'];

const botIntents = [
  BotIntent(
    'track',
    r'track|order status|where.*order|my order|dispatch',
    'You can track your parcel live with your order ID. Tracking details are also sent on WhatsApp and email once it ships.',
    actions: [BotAction(BotActionType.route, 'Open order tracking', route: '/track-order')],
  ),
  BotIntent(
    'recommend',
    r'choose|recommend|suggest|which|best|gift for|confused',
    'Happy to help! Here are our most-loved picks from both ranges:',
    products: ['ocean-escape', 'chai-parle-g-candle', 'heart-bowl-candle'],
    actions: [BotAction(BotActionType.route, 'Take the scent quiz', route: '/scent-finder')],
  ),
  BotIntent(
    'bulk',
    r'bulk|corporate|wedding|hamper|return gift|custom|quantity',
    'We make custom hampers for weddings, Diwali and teams — branded boxes and bulk pricing from 25 units. Share a few details and our gifting team will call you back within 24 hours.',
    actions: [BotAction(BotActionType.inquiry, 'Send a bulk inquiry', topic: 'Bulk / corporate gifting')],
  ),
  BotIntent(
    'shipping',
    r'ship|deliver|cod|cash on|how long|days|pincode|pin code',
    'Orders before 2 PM ship the same day. Metros get delivery in 2–3 days, rest of India in 4–6 days. {shipping} Cash on Delivery works on 22,000+ pin codes.',
  ),
  BotIntent(
    'returns',
    r'return|refund|damage|broken|replace|exchange',
    'Sorry about that! Notify us within 48 hours of delivery with an unboxing video or photos and we’ll send a free replacement. Returns are accepted within 7 days for unused items.',
    actions: [
      BotAction(BotActionType.whatsapp, 'Send photos on WhatsApp'),
      BotAction(BotActionType.route, 'Read return policy', route: '/policies/returns'),
    ],
  ),
  BotIntent(
    'pearled',
    r'pearl|reuse|refill|extinguish|spill|safe|kids|pets|wick',
    'Pearled candles are loose soy wax pearls — tip one over and the pearls smother the flame in about half a second. Only the melted pool is used, so you just add a fresh wick to reuse it.',
    actions: [BotAction(BotActionType.route, 'Shop pearled kits', route: '/shop?line=pearled')],
  ),
  BotIntent(
    'offers',
    r'coupon|discount|offer|code|sale|cheap|price',
    'Use code GLOW10 for 10% off your first order. Prices start at just ₹159.',
    actions: [BotAction(BotActionType.route, 'Browse all candles', route: '/shop')],
  ),
  BotIntent(
    'human',
    r'human|agent|person|call|talk|speak|support|contact|help',
    'Of course! Our team is available 24 hours, 7 days a week. Choose how you’d like to connect:',
    actions: [
      BotAction(BotActionType.whatsapp, 'Chat on WhatsApp'),
      BotAction(BotActionType.call, 'Call us now'),
      BotAction(BotActionType.inquiry, 'Leave a message', topic: 'Support'),
    ],
  ),
];

const botFallback = BotIntent(
  'fallback',
  r'$^',
  'I’m not sure I got that — but a real person can definitely help. Would you like to connect with our team?',
  actions: [
    BotAction(BotActionType.whatsapp, 'Chat on WhatsApp'),
    BotAction(BotActionType.inquiry, 'Leave a message', topic: 'Support'),
  ],
);

const inquiryTopics = ['Support', 'Order issue', 'Bulk / corporate gifting', 'Custom hamper', 'Product question'];

BotIntent botReply(String message) => botIntents.firstWhere((i) => i.matches(message), orElse: () => botFallback);
