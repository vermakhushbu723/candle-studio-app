/// Brand details and page copy — same as the website (candle-studio/src/data/site.js & content.js).
library;

class Site {
  Site._();

  static const name = 'Jyotessa';
  static const tagline = "The World's Safest & Endless Pearled Candle";
  static const subTagline = 'Life is too short to light boring candles.';
  static const mission =
      'We set out to remove the one thing standing between people and a lit candle: the fear of knocking it over. Pearled soy wax burns clean, spills nothing and refills forever — so ambience never has to be a risk.';
  static const supportEmail = 'support@jyotessa.com';
  static const whatsapp = '+91 93105 08371';
  static const phone = '+91 93105 08371';
  static const hours = 'Open 24 hours, 7 days a week';
  static const shipsTo = 'Handmade in India · Shipping Pan-India';
  static const address = 'Near Barat Ghar, Wajidpur, Sector 63, Noida, Uttar Pradesh 201301';
  static const googleMapsUrl =
      'https://www.google.com/maps/search/?api=1&query=Jyotessa%2C%20Wajidpur%2C%20Sector%2063%2C%20Noida%2C%20Uttar%20Pradesh%20201301';
  static const googleReviewUrl = 'https://g.page/r/CQ2T_G0wSr7nECE/review';
  static const instagram = 'https://www.instagram.com/jyotessa/';
  static const facebook = 'https://www.facebook.com/jyotessa/';

  static String get whatsappUrl => 'https://wa.me/${whatsapp.replaceAll(RegExp(r'\D'), '')}';
  static String get phoneUrl => 'tel:${phone.replaceAll(' ', '')}';
}

class SiteImages {
  SiteImages._();
  static const hero = '/images/site/hero-candle.webp';
  static const livingRoom = '/images/site/lifestyle-living-room.webp';
  static const proofPearled = '/images/site/proof-pearled.webp';
  static const proofTraditional = '/images/site/proof-traditional.webp';
  static const stepPour = '/images/site/step-pour.webp';
  static const stepIgnite = '/images/site/step-ignite.webp';
  static const beach = '/images/products/extra-beach-1.jpg';
  static const urli = '/images/products/extra-urli-1.webp';
  static const tulip = '/images/products/extra-tulip-1.jpg';
  static const matcha = '/images/products/extra-matcha-1.jpg';
  static const modak = '/images/products/extra-modak-1.jpg';
  static const daisy = '/images/products/extra-daisy-1.jpg';
}

const instagramFeed = [
  '/images/products/extra-beach-2.jpg',
  '/images/products/extra-modak-2.jpg',
  '/images/products/extra-tulip-2.jpg',
  '/images/products/extra-matcha-2.jpg',
  '/images/products/extra-urli-2.webp',
  '/images/products/extra-daisy-2.jpg',
];

const announcements = [
  '{shippingShort} · Pan-India',
  'Use code GLOW10 for 10% off your first order',
  'Cash on Delivery across 22,000+ pin codes',
  'Same-day dispatch on orders before 2 PM',
  'Hand-poured in India · 100% soy wax',
];

class Stat {
  const Stat(this.value, this.label, {this.suffix = '', this.decimals = 0});
  final double value;
  final String label;
  final String suffix;
  final int decimals;
}

const stats = [
  Stat(2143, 'Verified reviews', suffix: '+'),
  Stat(4.9, 'Average rating', suffix: '/5', decimals: 1),
  Stat(22000, 'Pin codes served', suffix: '+'),
  Stat(0.5, 'Auto-extinguish', suffix: 's', decimals: 1),
];

class Review {
  const Review(this.name, this.location, this.product, this.quote, [this.rating = 5]);
  final String name;
  final String location;
  final String product;
  final String quote;
  final int rating;
}

const reviews = [
  Review(
    'Ananya Menon',
    'Bengaluru',
    'The Ocean Escape',
    'My cat knocked it off the side table yesterday and it literally just went out without a drop of hot wax anywhere. Total gamechanger!',
  ),
  Review(
    'Rohan Kapadia',
    'Mumbai',
    'Boho Botanical',
    'Sent four of these as Diwali gifts. The dried lavender in the ribbed jar got me three phone calls. Two of them have already reordered refills.',
  ),
  Review(
    'Sneha Iyer',
    'Chennai',
    'The Mini Pocket Magic',
    'I have a toddler, so open flames were off the table for two years. Poured this into an old brass urli and I finally have my evenings back.',
  ),
  Review(
    'Devika Rathore',
    'Jaipur',
    'Chai & Parle-G Biscuit Candle',
    'It smells exactly like 5 PM at my nani’s house. I bought ten more for my office team and everyone wanted to know where it’s from.',
  ),
  Review(
    'Aditya Sharma',
    'New Delhi',
    'The Endless Refill & Scent Bar',
    'Bought it for the aesthetic, stayed for the refills. Pulling out the old pool and dropping in a new wick takes about ten seconds.',
  ),
  Review(
    'Farah Qureshi',
    'Hyderabad',
    'Bouquet Candle',
    'The bouquet is so detailed my mother refused to light it for a week. Packaging was gorgeous — felt like a luxury brand.',
  ),
];

class Faq {
  const Faq(this.q, this.a);
  final String q;
  final String a;
}

class FaqGroup {
  const FaqGroup(this.group, this.items);
  final String group;
  final List<Faq> items;
}

const faqs = [
  FaqGroup('Pearled Candles', [
    Faq(
      'How does the auto-extinguish feature work?',
      'A pearled candle is thousands of loose soy granules with air between them. Only a small pool around the wick is ever molten. Tip the vessel and the dry pearls avalanche over the flame and cut off its oxygen, extinguishing it in roughly half a second.',
    ),
    Faq(
      'Can I use my own essential oils with the pearls?',
      'Yes. Stir 8–10 drops of any skin-safe essential or fragrance oil into roughly 100g of pearls, mix for a few seconds, then pour. You can run lavender on a weeknight and amber oud for a dinner party from the very same bag.',
    ),
    Faq(
      'How long does 300g of Pearl Wax last?',
      'A standard 200g jar candle gives roughly 35–40 hours. 300g of pearl wax runs for approximately 55–65 burn hours, and only the melted pool is consumed — the surrounding pearls get reused.',
    ),
  ]),
  FaqGroup('Handcrafted Candles', [
    Faq(
      'Are the food-inspired candles safe to keep around kids?',
      'They are made with 100% soy wax and cotton wicks, but they look very real! Please keep them out of reach of small children and label them clearly when gifting.',
    ),
    Faq(
      'Why does my candle tunnel?',
      'On the first burn, let the wax pool reach the edges (2–3 hours). Soy wax has a memory, so a short first burn creates a tunnel that is hard to fix later.',
    ),
    Faq(
      'Do you make custom or bulk hampers?',
      'Yes — we create custom hampers for weddings, corporate Diwali gifting and return gifts. Reach out on WhatsApp or the contact form with quantity and budget.',
    ),
  ]),
  FaqGroup('Orders & Shipping', [
    Faq(
      'What are the shipping times across India?',
      'Orders placed before 2 PM IST are dispatched the same working day. Metro cities receive delivery in 2–3 days, the rest of India in 4–6 days, North-East and island territories in 6–8 days.',
    ),
    Faq('Is Cash on Delivery available?', 'Yes, COD is available across 22,000+ pin codes. {shipping}'),
    Faq(
      'What if my candle arrives damaged?',
      'Notify us within 48 hours of delivery with an unboxing video or clear photographs and we will send a free replacement.',
    ),
    Faq(
      'Is the soy wax safe around dogs and cats?',
      'The wax is 100% plant-based soy with no paraffin and no lead or zinc wick cores. Use unscented pearls for very sensitive pets and never leave a flame unattended.',
    ),
  ]),
];

class HowStep {
  const HowStep(this.title, this.body, this.image);
  final String title;
  final String body;
  final String image;
}

const howItWorks = [
  HowStep('Pour', 'Fill any heat-safe glass, bowl or vessel with pearl wax — right up to two-thirds full.', '/images/site/step-pour.webp'),
  HowStep('Insert', 'Plant a braided cotton wick in the centre, leaving about a quarter inch standing proud.', '/images/products/kit-tester.webp'),
  HowStep('Ignite', 'Light it and settle in. A soft pool forms around the wick — soot-free, smoke-free warmth.', '/images/site/step-ignite.webp'),
  HowStep('Refresh', 'Once cool, lift out the hardened pool, drop in a fresh wick, and the candle is brand new.', '/images/products/kit-refill.webp'),
];

class Perk {
  const Perk(this.title, this.body);
  final String title;
  final String body;
}

const whyUs = [
  Perk(
    'Spill-Proof & Safe',
    'Tip it over and the loose pearls collapse onto the flame, smothering it in under a second. No running wax, no scorched tabletops.',
  ),
  Perk('Infinite Reusability', 'Only the melted pool around the wick is spent. Lift it out, drop in a fresh wick, and the remaining pearls are good as new.'),
  Perk('Refill Any Vessel', 'Old whisky glasses, brass urlis, coconut shells, ceramic bowls — if it holds pearls, it becomes a designer candle.'),
  Perk('Clean & Non-Toxic', 'Zero soot, zero paraffin, zero lead cores. Just 100% plant-based soy wax that burns cool and leaves walls unmarked.'),
  Perk('Built from India', 'Jalebi rabri, chai Parle-G, mogra and monsoon — scents from real Indian life, not generic “ocean mist”.'),
  Perk('Gift-Ready Always', 'Every order ships in a keepsake box with a handwritten note option — no extra charge.'),
];

class Comparison {
  const Comparison(this.caption, this.points, this.image);
  final String caption;
  final List<String> points;
  final String image;
}

const comparisonPearled = Comparison('Pearled Candle', [
  'Self-extinguishes in ~0.5s',
  'No hot wax spill',
  'Reusable — just replace the wick',
  'Any vessel you own',
], SiteImages.proofPearled);
const comparisonTraditional = Comparison('Traditional Candle', [
  'Keeps burning on its side',
  'Hot wax pours across surfaces',
  'Jar is dead once wax is gone',
  'Fixed container',
], SiteImages.proofTraditional);

class QuizOption {
  const QuizOption(this.value, this.label);
  final String value;
  final String label;
}

class QuizQuestion {
  const QuizQuestion(this.id, this.question, this.options);
  final String id;
  final String question;
  final List<QuizOption> options;
}

const scentQuiz = [
  QuizQuestion('for', 'Who is it for?', [
    QuizOption('self', 'Me, obviously'),
    QuizOption('gift', 'A gift'),
    QuizOption('romance', 'My person'),
    QuizOption('host', 'Hosting guests'),
  ]),
  QuizQuestion('mood', 'Pick a mood', [
    QuizOption('calm', 'Calm & slow'),
    QuizOption('cozy', 'Cozy & nostalgic'),
    QuizOption('fresh', 'Fresh & airy'),
    QuizOption('festive', 'Festive & bold'),
  ]),
  QuizQuestion('budget', 'Your budget?', [QuizOption('budget', 'Under ₹500'), QuizOption('mid', '₹500 – ₹1,000'), QuizOption('premium', 'Treat yourself')]),
];

class ScentStory {
  const ScentStory(this.title, this.notes, this.line, this.image, this.productId);
  final String title;
  final String notes;
  final String line;
  final String image;
  final String productId;
}

const scentStories = [
  ScentStory(
    'Monsoon Chai',
    'Cardamom · Ginger · Warm milk',
    'Rain on the window, a kulhad in hand and a Parle-G dipped just long enough.',
    '/images/products/chai-parle-g-candle-2.jpg',
    'chai-parle-g-candle',
  ),
  ScentStory(
    'Seaside Dinner',
    'Ocean breeze · Sea salt · Driftwood',
    'Shells, floating pearls and a long table that nobody wants to leave.',
    '/images/products/kit-ocean.webp',
    'ocean-escape',
  ),
  ScentStory(
    'Diwali Night',
    'Sandalwood · Marigold · Ghee diya',
    'Rangoli at the door, a brass urli glowing at the centre of it all.',
    '/images/products/kamal-jyoti-urli-2.webp',
    'kamal-jyoti-urli',
  ),
  ScentStory(
    'First Anniversary',
    'Velvet rose · Soft musk',
    'A bowl of tiny hearts for the person who remembers every little thing.',
    '/images/products/heart-bowl-candle-2.jpg',
    'heart-bowl-candle',
  ),
  ScentStory(
    'Sunday Halwai',
    'Saffron · Caramel · Rabdi',
    'The smell of hot jalebis drifting in from the corner sweet shop.',
    '/images/products/jalebi-rabdi-candle-2.jpg',
    'jalebi-rabdi-candle',
  ),
  ScentStory(
    'Slow Mornings',
    'Lavender · Vanilla foam',
    'No alarms, no hurry — just a latte and a flickering flame.',
    '/images/products/lavender-latte-candle-1.jpg',
    'lavender-latte-candle',
  ),
];

const giftingProducts = ['kamal-jyoti-urli', 'festive-diya-set', 'dry-fruit-delight'];
const heroAvatarProducts = ['chai-parle-g-candle', 'bouquet-candle', 'heart-bowl-candle'];

// ——— About page

const aboutStory = [
  'A regular candle is a single block of wax — tip it, and everything it’s made of comes pouring out with the flame still attached. We didn’t think that trade-off was necessary just to get warm, flickering light in a room.',
  'Pearled wax replaces that block with thousands of loose soy pearls. Only the small pool immediately around the wick is ever molten; the rest stays solid, dry and inert. Knock it over, and the dry pearls avalanche across the flame the way sand smothers a spark — no running wax, no scorched wood, no panic.',
  'The same structure that makes it safe also makes it reusable: once the melted pool hardens, lifting it out and dropping in a fresh wick turns the same jar into a brand-new candle. One pouch, refilled indefinitely, in whatever glass, bowl or shell you already own.',
  'Alongside the pearls, we hand-pour Indian-inspired candles — chai and Parle-G, jalebi and rabdi, brass urlis for Diwali — because life is too short to light boring candles.',
];

class Milestone {
  const Milestone(this.year, this.title, this.body);
  final String year;
  final String title;
  final String body;
}

const milestones = [
  Milestone('2021', 'A kitchen experiment', 'The first chai-and-biscuit candle was poured on a stovetop for a friend’s birthday.'),
  Milestone('2022', 'Handcrafted studio', 'Food-inspired and floral collections launched, hand-poured by a team of six.'),
  Milestone('2024', 'The pearl idea', 'After a toddler knocked over a jar candle, we started testing loose soy pearls. It changed everything.'),
  Milestone('2026', 'One home for both', 'Pearled kits and handcrafted candles now live together under one roof — Jyotessa.'),
];

const aboutProof = [('4.9/5', 'Average rating'), ('2,000+', 'Happy homes'), ('0', 'Spill complaints')];

// ——— Policies & disclaimer

class PolicySection {
  const PolicySection(this.heading, {this.text, this.bullets});
  final String heading;
  final String? text;
  final List<String>? bullets;
}

class Policy {
  const Policy(this.title, this.sections);
  final String title;
  final List<PolicySection> sections;
}

const policies = {
  'shipping': Policy('Shipping Policy', [
    PolicySection('Dispatch', text: 'Orders placed before 2 PM IST are dispatched the same working day. Tracking details are shared over email and WhatsApp.'),
    PolicySection('Delivery Timelines', text: 'Metro cities — 2 to 3 days. Rest of India — 4 to 6 days. North-East and island territories — 6 to 8 days.'),
    PolicySection('Shipping Charges', text: '{shipping} COD is available across 22,000+ pin codes.'),
  ]),
  'returns': Policy('Return, Refund & Replacement Policy', [
    PolicySection(
      'Return Window',
      text: 'Return or replacement requests can be raised within 7 days of delivery. Products must be unused and in original packaging.',
    ),
    PolicySection('Damaged Products', text: 'Notify us within 48 hours of delivery and share an unboxing video or clear photographs.'),
    PolicySection('Refunds', text: 'Approved refunds are processed to the original payment method within 5–7 working days after quality check.'),
  ]),
  'privacy': Policy('Privacy Policy', [
    PolicySection('What we collect', text: 'Name, contact details and address required to fulfil your order. We never sell your data.'),
    PolicySection('Payments', text: 'All payments are processed by secure, PCI-compliant partners. We do not store card details.'),
  ]),
  'terms': Policy('Terms of Service', [
    PolicySection(
      'Product Safety',
      text: 'Our candles involve a genuine open flame. Never leave a lit candle unattended and burn on a stable, heat-safe surface.',
    ),
    PolicySection(
      'Liability',
      text: 'The auto-extinguish behaviour reduces spill risk under normal use — it does not remove the need for usual candle-safety precautions.',
    ),
  ]),
  'disclaimer': Policy('Disclaimer', [
    PolicySection(
      'Open Flame & Product Safety',
      bullets: [
        'Our candles involve a genuine open flame. Never leave a lit candle unattended, and always burn it on a stable, heat-safe surface away from curtains, paper and other flammable material.',
        'Keep burning candles and loose wax pearls out of reach of young children and pets. Adult supervision is required at all times while a candle is lit.',
        'The auto-extinguish behaviour described in this app reduces spill risk under normal use — it is not a guarantee against fire in every circumstance, and it does not remove the need for the usual candle-safety precautions above.',
        'Fragrance oils and dyes should be kept away from eyes and broken skin, and used only in the quantities suggested. Discontinue use if irritation occurs.',
      ],
    ),
    PolicySection(
      'Website & App Content',
      bullets: [
        'We try to keep product descriptions, pricing and imagery accurate and up to date, but we do not warrant that every detail is complete, current or error-free.',
        'Photographs are for illustration — actual pearl colour, jar shape and included decor may vary slightly by batch.',
        'Customer reviews and testimonials reflect individual experiences. They are not a guarantee that you will have the same result.',
      ],
    ),
    PolicySection(
      'External Links',
      text:
          'This app may link to third-party pages, such as our Instagram, Facebook or WhatsApp. Jyotessa does not control and is not responsible for the content, policies or practices of any third-party site.',
    ),
    PolicySection(
      'Limitation of Liability',
      bullets: [
        'To the fullest extent permitted by law, Jyotessa is not liable for any indirect, incidental or consequential loss or damage arising from the use, or inability to use, our products or this app, including damage caused by misuse or by ignoring the safety guidance above.',
        'Nothing in this disclaimer limits any right you have under applicable Indian consumer-protection law, including your rights under our Return, Refund & Replacement Policy.',
      ],
    ),
    PolicySection('Contact Us', text: 'Questions about this disclaimer can be sent to ${Site.supportEmail} or ${Site.phone}.'),
  ]),
};

/// Contact form topics (POST /inquiries).
const contactTopics = [('order', 'Order support'), ('bulk', 'Bulk / corporate gifting'), ('custom', 'Custom hamper'), ('other', 'Something else')];
