/// Brand details and page copy — same as the website (candle-studio/src/data/site.js & content.js).
library;

class Site {
  Site._();

  static const name = 'Jyotessa';
  static const tagline = 'Hand-poured candles for every celebration';
  static const subTagline = 'Life is too short to light boring candles.';
  static const mission =
      'We hand-pour candles that make everyday moments feel festive — terracotta diyas and lotus bowls for pooja, rose bouquets for the people you love, and sweet-shop treats you can light. Small batches, clean-burning wax and gift-ready packing, shipped across India.';
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
  'Hand-poured in India · 48 handmade designs',
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
  Stat(48, 'Handmade designs'),
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
    'Water-Pond Lotus Candle',
    'The lotus bowl looked so pretty in my pooja corner that my mother asked for two more. Lovely finishing and very neatly packed.',
  ),
  Review(
    'Rohan Kapadia',
    'Mumbai',
    'Designer Wax Diya Set',
    'Ordered the 12-diya combo for Diwali gifting. Burnt evenly, no oil mess, and everyone loved the carved rims.',
  ),
  Review(
    'Sneha Iyer',
    'Chennai',
    'Motichoor Ladoo & Modak Candle Box',
    'They genuinely look like real sweets! Gave them as Ganpati return gifts and the kids were amazed.',
  ),
  Review(
    'Devika Rathore',
    'Jaipur',
    '3x3 Rose Pattern Bubble Candle',
    'Bought the rose cube for our anniversary — it is even prettier in person. Packed beautifully.',
  ),
  Review(
    'Aditya Sharma',
    'New Delhi',
    'Slanted Gel & Hearts Glass Candle',
    'The gel-and-hearts glass is so aesthetic on my desk. Gifted one to my sister too.',
  ),
  Review(
    'Farah Qureshi',
    'Hyderabad',
    '3D Sitting Teddy Bear Candle',
    'Tiny, detailed and super cute. Perfect little add-on for a birthday hamper.',
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
  FaqGroup('Our Candles', [
    Faq(
      'What are your candles made of?',
      'Our candles are hand-poured in small batches with clean-burning candle wax and cotton wicks. Gel candles use a clear candle gel, and diyas and lotus bowls come in terracotta or brass holders.',
    ),
    Faq(
      'How long does a candle burn?',
      'It depends on the size: tea lights burn for about 3–4 hours, small sculpted candles for 4–8 hours and larger tins and glasses for longer. Burn for up to 3–4 hours at a time and trim the wick to 5 mm before each burn.',
    ),
    Faq(
      'Do the floating candles really float?',
      'Yes — our mini rose and daisy floating candles are made to float on water. Place them gently in a bowl, urli or pool and light them with a long lighter.',
    ),
    Faq(
      'Are the sweet-shaped candles safe around kids?',
      'They look very real, so please keep ladoo, modak and rasgulla candles out of reach of small children and label them clearly when gifting.',
    ),
  ]),
  FaqGroup('Gifting & Custom Orders', [
    Faq(
      'Do you make custom or bulk hampers?',
      'Yes — we make custom hampers for weddings, corporate Diwali gifting and return gifts. Reach out on WhatsApp or the contact form with quantity and budget.',
    ),
    Faq(
      'Is the packaging gift-ready?',
      'Every order is packed with care, and gift boxes come ready to gift. Add a gift note at checkout and we will handwrite it on a card for free.',
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
  ]),
];

class HowStep {
  const HowStep(this.title, this.body, this.image);
  final String title;
  final String body;
  final String image;
}

const howItWorks = [
  HowStep('Trim', 'Trim the wick to about 5 mm before every burn for a clean, steady flame.', '/images/products/catalog/designer-diya.jpg'),
  HowStep('Place', 'Set the candle on a stable, heat-safe surface — away from curtains, drafts, children and pets.', '/images/products/catalog/lotus-pond.jpg'),
  HowStep('Light', 'Light it and enjoy the glow. Floating candles go gently on water in a bowl or urli.', '/images/products/catalog/heart-gel-glass.jpg'),
  HowStep('Put out', 'Burn for up to 3–4 hours at a time, then snuff it out — never leave a lit candle unattended.', '/images/products/catalog/rose-bubble.jpg'),
];

class Perk {
  const Perk(this.title, this.body);
  final String title;
  final String body;
}

const whyUs = [
  Perk('Hand-Poured in India', 'Every candle is poured and finished by hand in small batches — no two are exactly alike.'),
  Perk('Made for Festivals', 'Diyas, lotus bowls and sweet-shop candles made for Diwali, pooja, Ganpati and every celebration.'),
  Perk('Clean-Burning', 'Quality wax and cotton wicks for a steady, even burn and minimal smoke.'),
  Perk('Gifts Under ₹500', 'From ₹35 tea-light sets to ₹499 gift boxes — thoughtful gifts for every budget.'),
  Perk('Custom & Bulk Orders', 'Wedding favours, Diwali hampers and corporate gifting — tell us the quantity and we will make it happen.'),
  Perk('Gift-Ready Always', 'Every order is packed with care, with a free handwritten note option.'),
];

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
    'Diwali Night',
    'Diyas · Rangoli · Family',
    'Rows of carved terracotta diyas glowing at the door, with no oil and no mess.',
    '/images/products/catalog/designer-diya.jpg',
    'designer-diya-pack-of-12',
  ),
  ScentStory('Morning Pooja', 'Brass · Lotus · Calm', 'A little lotus pond in a brass bowl, lit beside the mandir at sunrise.', '/images/products/catalog/lotus-pond.jpg', 'lotus-pond'),
  ScentStory(
    'Ganpati Bappa',
    'Modak · Ladoo · Celebration',
    'Motichoor ladoos and modaks you can light — the sweetest return gift.',
    '/images/products/catalog/ladoo-modak.jpg',
    'ladoo-modak',
  ),
  ScentStory(
    'First Anniversary',
    'Roses · Pink · Romance',
    'A cube of sculpted roses for the person who remembers every little thing.',
    '/images/products/catalog/rose-bubble.jpg',
    'rose-bubble',
  ),
  ScentStory('Cosy Corner', 'Gel · Hearts · Glow', 'Slanted gel and tiny hearts in a glass, flickering on your bedside table.', '/images/products/catalog/heart-gel-glass.jpg', 'heart-gel-glass'),
  ScentStory('Teddy Day', 'Cute · Gifting · Smiles', 'A little sitting teddy that is almost too cute to light.', '/images/products/catalog/teddy-bear.jpg', 'teddy-bear'),
];

const giftingProducts = ['lotus-pond-pack-of-4', 'designer-diya-pack-of-12', 'ladoo-modak'];
const heroAvatarProducts = ['lotus-pond', 'rose-bubble', 'teddy-bear'];

// ——— About page

const aboutStory = [
  'Jyotessa began at a kitchen stove, pouring candles as gifts for friends and family. The joy on their faces when a diya or a little rose candle was lit is what we still pour into every piece.',
  'Today we make 48 designs by hand — terracotta wax diyas and lotus water-pond bowls for pooja and Diwali, ladoo, modak and rasgulla candles that look good enough to eat, rose bouquets and rose bubble cubes for the people you love, gel glasses, mandala tins, floating candles and tea lights for every corner of your home.',
  'Every candle is poured in small batches, finished by hand and packed gift-ready, then shipped across India with Cash on Delivery — because life is too short to light boring candles.',
];

class Milestone {
  const Milestone(this.year, this.title, this.body);
  final String year;
  final String title;
  final String body;
}

const milestones = [
  Milestone('2021', 'A kitchen experiment', 'The first candles were poured on a stovetop as gifts for friends and family.'),
  Milestone('2023', 'Festive favourites', 'Diyas, lotus bowls and sweet-shop candles became our Diwali and Ganpati best-loved range.'),
  Milestone('2025', 'Roses & bubbles', 'Rose bouquets, bubble cubes and gel glasses joined the collection for gifting and décor.'),
  Milestone('2026', 'Jyotessa online', 'All 48 designs now ship across India from our studio in Noida.'),
];

const aboutProof = [('4.9/5', 'Average rating'), ('2,000+', 'Happy homes'), ('48', 'Handmade designs')];

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
      text: 'Candles involve an open flame. Keep them away from children, pets and anything flammable, and follow the care instructions on each product.',
    ),
  ]),
  'disclaimer': Policy('Disclaimer', [
    PolicySection(
      'Open Flame & Product Safety',
      bullets: [
        'Our candles involve a genuine open flame. Never leave a lit candle unattended, and always burn it on a stable, heat-safe surface away from curtains, paper and other flammable material.',
        'Keep burning candles and wax out of reach of young children and pets. Adult supervision is required at all times while a candle is lit.',
        'Sweet- and food-shaped candles look very real — they are not edible. Label them clearly when gifting and keep them away from small children.',
        'Fragrance oils and dyes should be kept away from eyes and broken skin, and used only in the quantities suggested. Discontinue use if irritation occurs.',
      ],
    ),
    PolicySection(
      'Website & App Content',
      bullets: [
        'We try to keep product descriptions, pricing and imagery accurate and up to date, but we do not warrant that every detail is complete, current or error-free.',
        'Photographs are for illustration — actual colour, shape and included décor may vary slightly by batch, as every candle is hand-poured.',
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
