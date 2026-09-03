import { useState, useEffect, useRef } from "react";

// ─── Types ───────────────────────────────────────────────────────────────────
type Tab = "home" | "news" | "sports" | "jobs" | "more";
type MoreSection = "tech" | "directory" | "prayer" | "favorites" | "settings" | "notifications";
type NewsCategory = "all" | "ksa" | "economy" | "business" | "education" | "health" | "society" | "tourism" | "vision2030";
type TechCategory = "all" | "ai" | "phones" | "apps" | "games" | "security" | "companies";
type SportsCategory = "all" | "league" | "clubs" | "players" | "international";
type JobsCategory = "all" | "riyadh" | "jeddah" | "dammam" | "remote";

// ─── Data ────────────────────────────────────────────────────────────────────
const breakingNews = [
  "🔴 عاجل: مجلس الوزراء يعقد جلسته الأسبوعية برئاسة ولي العهد",
  "🔴 عاجل: ارتفاع أسعار النفط بعد قرارات أوبك+",
  "🔴 عاجل: المملكة تسجل نموًا اقتصاديًا بنسبة 6.4% في الربع الثالث",
  "🔴 عاجل: الهلال يتصدر دوري روشن بعد فوز كبير",
];

const newsArticles = [
  {
    id: 1, category: "ksa",
    title: "المملكة تطلق أكبر مشروع طاقة شمسية في العالم بنيوم",
    source: "العربية", time: "منذ ٥ دقائق", reads: "٢٤,٥٠٠",
    img: "https://images.unsplash.com/photo-1509391366360-2e959784a276?w=600&h=350&fit=crop&auto=format",
    excerpt: "أعلنت المملكة العربية السعودية عن إطلاق مشروع طاقة شمسية ضخم في منطقة نيوم بقدرة تتجاوز ١٠ جيجاوات.",
    tags: ["رؤية 2030", "طاقة متجددة", "نيوم"]
  },
  {
    id: 2, category: "economy",
    title: "صندوق الاستثمارات العامة يضخ ٢٠٠ مليار ريال في مشاريع التنويع الاقتصادي",
    source: "سكاي نيوز عربية", time: "منذ ٢٠ دقيقة", reads: "١٨,٢٠٠",
    img: "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=600&h=350&fit=crop&auto=format",
    excerpt: "كشف صندوق الاستثمارات العامة عن خطة طموحة للاستثمار في قطاعات التقنية والترفيه والسياحة.",
    tags: ["اقتصاد", "استثمار", "تنويع"]
  },
  {
    id: 3, category: "health",
    title: "منظمة الصحة العالمية تشيد بالمنظومة الصحية السعودية وتضعها بين الأفضل عالميًا",
    source: "صحيفة الرياض", time: "منذ ٤٥ دقيقة", reads: "١٢,٨٠٠",
    img: "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=600&h=350&fit=crop&auto=format",
    excerpt: "حصلت المنظومة الصحية السعودية على تقييم متقدم في التقرير السنوي لمنظمة الصحة العالمية.",
    tags: ["صحة", "منظمة دولية"]
  },
  {
    id: 4, category: "tourism",
    title: "السياحة السعودية تسجل رقمًا قياسيًا بـ ١٠٠ مليون زيارة خلال ٢٠٢٤",
    source: "CNN عربي", time: "منذ ساعة", reads: "٩,٤٠٠",
    img: "https://images.unsplash.com/photo-1547234935-80c7145ec969?w=600&h=350&fit=crop&auto=format",
    excerpt: "أعلنت هيئة السياحة السعودية عن تجاوز عدد الزوار حاجز ١٠٠ مليون زيارة للعام الثالث على التوالي.",
    tags: ["سياحة", "رقم قياسي"]
  },
  {
    id: 5, category: "education",
    title: "جامعة الملك عبدالله للعلوم تحتل المرتبة الأولى على مستوى الشرق الأوسط",
    source: "مدى مصر", time: "منذ ساعتين", reads: "٧,١٠٠",
    img: "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=600&h=350&fit=crop&auto=format",
    excerpt: "أعلنت جامعة الملك عبدالله للعلوم والتقنية (كاوست) حصولها على المرتبة الأولى في تصنيف المشنق.",
    tags: ["تعليم", "بحث علمي"]
  },
  {
    id: 6, category: "vision2030",
    title: "رؤية ٢٠٣٠: إنجازات قياسية في ٨ سنوات من التحول الشامل",
    source: "واس", time: "منذ ٣ ساعات", reads: "٣١,٠٠٠",
    img: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&h=350&fit=crop&auto=format",
    excerpt: "احتفلت المملكة بإنجازات رؤية ٢٠٣٠ ضمن مؤتمر رؤية السعودية السنوي بحضور عالمي واسع.",
    tags: ["رؤية 2030", "إنجازات"]
  },
];

const techArticles = [
  {
    id: 101, category: "ai",
    title: "سدايا تطلق نموذج اللغة العربي الكبير 'جيل' بمنافسة عالمية",
    source: "تقنية", time: "منذ ١٠ دقائق", reads: "٤٥,٠٠٠",
    img: "https://images.unsplash.com/photo-1677442135703-1787eea5ce01?w=600&h=350&fit=crop&auto=format",
    excerpt: "أطلقت الهيئة السعودية للبيانات والذكاء الاصطناعي نموذج اللغة العربي الكبير الذي يُعد الأقوى عربيًا.",
    tags: ["ذكاء اصطناعي", "سدايا", "لغة عربية"]
  },
  {
    id: 102, category: "phones",
    title: "سامسونج تكشف عن Galaxy S25 Ultra: كاميرا ٢٠٠ ميجابكسل وذكاء اصطناعي متقدم",
    source: "أندرويد عرب", time: "منذ ٣٠ دقيقة", reads: "٢٨,٣٠٠",
    img: "https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=600&h=350&fit=crop&auto=format",
    excerpt: "كشفت سامسونج عن هاتفها الرائد الجديد بمواصفات غير مسبوقة ومزايا ذكاء اصطناعي ثورية.",
    tags: ["سامسونج", "هواتف", "كاميرا"]
  },
  {
    id: 103, category: "security",
    title: "تحذير أمني: ثغرة خطيرة تطال ملايين الأجهزة التي تعمل بنظام أندرويد",
    source: "كاسبرسكي", time: "منذ ساعة", reads: "١٩,٧٠٠",
    img: "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=600&h=350&fit=crop&auto=format",
    excerpt: "اكتشف باحثو الأمن السيبراني ثغرة أمنية خطيرة تؤثر على أجهزة أندرويد بإصدارات متعددة.",
    tags: ["أمن سيبراني", "أندرويد", "تحذير"]
  },
  {
    id: 104, category: "companies",
    title: "أرامكو تدشن مركز ابتكار التقنية الرقمية في الرياض بميزانية ٥ مليارات دولار",
    source: "فوربس عربية", time: "منذ ٢ ساعة", reads: "١٤,٢٠٠",
    img: "https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&h=350&fit=crop&auto=format",
    excerpt: "أعلنت أرامكو السعودية عن تدشين مركز الابتكار التقني الرقمي الأكبر في الشرق الأوسط.",
    tags: ["أرامكو", "ابتكار", "تقنية"]
  },
];

const matches = [
  {
    id: 1, league: "دوري روشن السعودي",
    homeTeam: "الهلال", homeScore: 3, homeLogo: "https://upload.wikimedia.org/wikipedia/en/thumb/f/f7/Al-Hilal_Saudi_FC_logo.svg/1200px-Al-Hilal_Saudi_FC_logo.svg.png",
    awayTeam: "النصر", awayScore: 0, awayLogo: "https://upload.wikimedia.org/wikipedia/en/thumb/c/ce/Al-Nassr_FC_logo.svg/1200px-Al-Nassr_FC_logo.svg.png",
    status: "انتهت", time: "21:00", date: "2026-09-01"
  },
  {
    id: 2, league: "دوري روشن السعودي",
    homeTeam: "الاتحاد", homeScore: 0, homeLogo: "https://upload.wikimedia.org/wikipedia/en/thumb/f/f9/Al-Ittihad_Saudi_Club_logo.svg/1200px-Al-Ittihad_Saudi_Club_logo.svg.png",
    awayTeam: "الأهلي", awayScore: 0, awayLogo: "https://upload.wikimedia.org/wikipedia/en/thumb/9/9f/Al-Ahli_Saudi_FC_logo.svg/1200px-Al-Ahli_Saudi_FC_logo.svg.png",
    status: "قادمة", time: "20:00", date: "2026-09-02"
  },
];

const leagueNews = [
  {
    id: 201,
    title: "الهلال يسحق الاتحاد بثلاثية ويتصدر الدوري بفارق ٥ نقاط",
    source: "سبورت 360", time: "منذ ١٠ دق", reads: "٥٢,٠٠٠",
    img: "https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=600&h=350&fit=crop&auto=format",
    excerpt: "حقق الهلال فوزًا كبيرًا على الاتحاد بثلاثة أهداف مقابل هدف وحيد في الجولة الـ ١٨ من دوري روشن للمحترفين.",
    tags: ["الهلال", "دوري روشن"]
  },
  {
    id: 202,
    title: "رونالدو يسجل هاتريك ويقود النصر للتعادل أمام الأهلي",
    source: "العربية الرياضية", time: "منذ ٣٠ دق", reads: "٨٧,٠٠٠",
    img: "https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=600&h=350&fit=crop&auto=format",
    excerpt: "سجّل النجم البرتغالي كريستيانو رونالدو ثلاثية تاريخية أنقذت النصر من الهزيمة أمام الأهلي في مباراة مثيرة.",
    tags: ["النصر", "رونالدو", "دوري روشن"]
  },
  {
    id: 203,
    title: "نيمار يعود للتدريبات مع الاتحاد بعد غياب طويل بسبب الإصابة",
    source: "كووورة", time: "منذ ساعتين", reads: "٣٤,٠٠٠",
    img: "https://images.unsplash.com/photo-1551958219-acbc608c6377?w=600&h=350&fit=crop&auto=format",
    excerpt: "عاد النجم البرازيلي نيمار جونيور إلى التدريبات الجماعية مع فريق الاتحاد استعدادًا للمشاركة في الجولات القادمة.",
    tags: ["الاتحاد", "نيمار"]
  },
  {
    id: 204,
    title: "الدوري السعودي يتصدر الأندية الأعلى إنفاقًا في العالم لهذا الموسم",
    source: "فرانس فوتبول", time: "منذ ٣ ساعات", reads: "٢١,٥٠٠",
    img: "https://images.unsplash.com/photo-1459865264687-595d652de67e?w=600&h=350&fit=crop&auto=format",
    excerpt: "كشف تقرير دولي أن أندية دوري روشن للمحترفين أنفقت ما يزيد على ٣ مليارات دولار في ميزانيات الانتقالات هذا الموسم.",
    tags: ["دوري روشن", "انتقالات"]
  },
];

const leagueTable = [
  { pos: 1, team: "الهلال", p: 20, w: 18, d: 2, l: 0, pts: 56, logo: "https://upload.wikimedia.org/wikipedia/en/thumb/f/f7/Al-Hilal_Saudi_FC_logo.svg/1200px-Al-Hilal_Saudi_FC_logo.svg.png" },
  { pos: 2, team: "النصر", p: 20, w: 15, d: 2, l: 3, pts: 47, logo: "https://upload.wikimedia.org/wikipedia/en/thumb/c/ce/Al-Nassr_FC_logo.svg/1200px-Al-Nassr_FC_logo.svg.png" },
  { pos: 3, team: "الأهلي", p: 20, w: 12, d: 4, l: 4, pts: 40, logo: "https://upload.wikimedia.org/wikipedia/en/thumb/9/9f/Al-Ahli_Saudi_FC_logo.svg/1200px-Al-Ahli_Saudi_FC_logo.svg.png" },
  { pos: 4, team: "التعاون", p: 20, w: 10, d: 5, l: 5, pts: 35, logo: "https://upload.wikimedia.org/wikipedia/ar/e/e0/%D8%B4%D8%B9%D8%A7%D8%B1_%D9%86%D8%A7%D8%AF%D9%8A_%D8%A7%D9%84%D8%AA%D8%B9%D8%A7%D9%88%D9%86.png" },
];

const jobs = [
  {
    id: 1, title: "مهندس برمجيات أول", company: "أرامكو السعودية",
    city: "الظهران", type: "دوام كامل", field: "tech",
    experience: "٥+ سنوات", salary: "٣٠,٠٠٠ - ٤٥,٠٠٠ ريال",
    date: "منذ يوم", logo: "🏭", urgent: true
  },
  {
    id: 2, title: "مدير تسويق رقمي", company: "STC",
    city: "الرياض", type: "دوام كامل", field: "marketing",
    experience: "٣-٥ سنوات", salary: "٢٠,٠٠٠ - ٣٠,٠٠٠ ريال",
    date: "منذ يومين", logo: "📱", urgent: false
  },
  {
    id: 3, title: "محلل مالي", company: "بنك الراجحي",
    city: "الرياض", type: "دوام كامل", field: "finance",
    experience: "٢-٤ سنوات", salary: "١٥,٠٠٠ - ٢٢,٠٠٠ ريال",
    date: "منذ ٣ أيام", logo: "🏦", urgent: false
  },
  {
    id: 4, title: "مطور تطبيقات Flutter", company: "نيوم",
    city: "تبوك", type: "دوام كامل", field: "tech",
    experience: "٣+ سنوات", salary: "٢٥,٠٠٠ - ٣٥,٠٠٠ ريال",
    date: "منذ ٤ أيام", logo: "🌊", urgent: true
  },
  {
    id: 5, title: "طبيب تخصص طب الأسرة", company: "وزارة الصحة",
    city: "جدة", type: "دوام كامل", field: "health",
    experience: "حديث التخرج", salary: "١٨,٠٠٠ - ٢٥,٠٠٠ ريال",
    date: "منذ ٥ أيام", logo: "🏥", urgent: false
  },
  {
    id: 6, title: "مصمم UX/UI", company: "تمارا",
    city: "الرياض", type: "عن بُعد", field: "design",
    experience: "٢+ سنوات", salary: "١٢,٠٠٠ - ١٨,٠٠٠ ريال",
    date: "منذ أسبوع", logo: "💳", urgent: false
  },
];

const directory = [
  { id: 1, name: "مستشفى الملك فيصل التخصصي", cat: "مستشفيات", phone: "920012220", city: "الرياض", address: "حي الملك فهد، الرياض", rating: 4.8 },
  { id: 2, name: "وزارة الداخلية", cat: "حكومي", phone: "920004444", city: "الرياض", address: "طريق الملك عبدالعزيز، الرياض", rating: 4.2 },
  { id: 3, name: "مطعم البيك", cat: "مطاعم", phone: "920002626", city: "جدة", address: "طريق الملك عبدالله، جدة", rating: 4.7 },
  { id: 4, name: "شركة STC للاتصالات", cat: "اتصالات", phone: "900", city: "الرياض", address: "طريق الملك فهد، الرياض", rating: 3.9 },
  { id: 5, name: "طيران ناس", cat: "طيران", phone: "920002288", city: "جدة", address: "مطار الملك عبدالعزيز، جدة", rating: 4.1 },
  { id: 6, name: "المستشفى السعودي الألماني", cat: "مستشفيات", phone: "920001111", city: "جدة", address: "شارع التحلية، جدة", rating: 4.5 },
  { id: 7, name: "هيئة الزكاة والضريبة", cat: "حكومي", phone: "19993", city: "الرياض", address: "حي العقيق، الرياض", rating: 4.0 },
  { id: 8, name: "مطعم نايف للمندي", cat: "مطاعم", phone: "0112345678", city: "الرياض", address: "حي الملز، الرياض", rating: 4.6 },
];

const prayerTimes = {
  city: "الرياض",
  date: "الأربعاء، ٢٧ أغسطس ٢٠٢٦",
  hijri: "٢ صفر ١٤٤٨",
  times: [
    { name: "الفجر", time: "٤:٢٨", icon: "🌙" },
    { name: "الشروق", time: "٥:٥٢", icon: "🌅" },
    { name: "الظهر", time: "١٢:١٦", icon: "☀️" },
    { name: "العصر", time: "١٥:٤٠", icon: "🌤" },
    { name: "المغرب", time: "١٨:٤٠", icon: "🌇" },
    { name: "العشاء", time: "٢٠:١٠", icon: "🌃" },
  ],
  next: { name: "المغرب", remaining: "٢:٣٤:١٢" },
};

const cities = ["الرياض", "جدة", "مكة المكرمة", "المدينة المنورة", "الدمام", "الخبر", "تبوك", "أبها"];

// ─── Components ──────────────────────────────────────────────────────────────

function StatusBar({ dark }: { dark: boolean }) {
  const [time, setTime] = useState(new Date());
  useEffect(() => {
    const t = setInterval(() => setTime(new Date()), 1000);
    return () => clearInterval(t);
  }, []);
  return (
    <div className={`flex justify-between items-center px-4 pt-2 pb-1 text-xs font-semibold ${dark ? "text-gray-300" : "text-gray-700"}`}>
      <span>{time.toLocaleTimeString("ar-SA", { hour: "2-digit", minute: "2-digit" })}</span>
      <div className="flex gap-1 items-center">
        <span>●●●●</span>
        <span>WiFi</span>
        <span>🔋</span>
      </div>
    </div>
  );
}

function AppHeader({ title, dark, showBack, onBack }: { title: string; dark: boolean; showBack?: boolean; onBack?: () => void }) {
  return (
    <div className={`px-4 py-3 flex items-center gap-3 border-b ${dark ? "bg-[#161b22] border-gray-800" : "bg-white border-gray-100"} shadow-sm`}>
      {showBack && (
        <button onClick={onBack} className="text-[#006C35] dark:text-[#00a651] font-bold text-lg">‹</button>
      )}
      <div className="flex items-center gap-2">
        <div className="w-8 h-8 bg-[#006C35] rounded-lg flex items-center justify-center text-white text-sm font-bold">س</div>
        <span className={`font-bold text-lg ${dark ? "text-white" : "text-gray-900"}`}>{title}</span>
      </div>
    </div>
  );
}

function BreakingTicker({ dark }: { dark: boolean }) {
  const [idx, setIdx] = useState(0);
  useEffect(() => {
    const t = setInterval(() => setIdx(i => (i + 1) % breakingNews.length), 4000);
    return () => clearInterval(t);
  }, []);
  return (
    <div className={`flex items-center gap-2 px-4 py-2 ${dark ? "bg-red-900/30" : "bg-red-50"} border-b ${dark ? "border-red-800/40" : "border-red-100"}`}>
      <span className={`text-xs font-bold px-2 py-0.5 rounded ${dark ? "bg-red-700 text-white" : "bg-red-600 text-white"} shrink-0 pulse-dot`}>عاجل</span>
      <span className={`text-xs font-medium truncate ${dark ? "text-red-200" : "text-red-800"}`}>{breakingNews[idx]}</span>
    </div>
  );
}

function NewsCard({ article, dark, onFavorite, isFav }: { article: typeof newsArticles[0]; dark: boolean; onFavorite: (id: number) => void; isFav: boolean }) {
  return (
    <div className={`rounded-2xl overflow-hidden shadow-sm border ${dark ? "bg-[#161b22] border-gray-800" : "bg-white border-gray-100"} mb-3`}>
      <div className="relative">
        <img src={article.img} alt={article.title} className="w-full h-44 object-cover bg-gray-200" />
        <button
          onClick={() => onFavorite(article.id)}
          className={`absolute top-2 left-2 w-8 h-8 rounded-full flex items-center justify-center shadow-md ${isFav ? "bg-[#006C35] text-white" : "bg-white/80 text-gray-600"}`}
        >
          {isFav ? "♥" : "♡"}
        </button>
        <div className="absolute bottom-2 right-2 flex gap-1">
          {article.tags.slice(0, 2).map(t => (
            <span key={t} className="text-[10px] bg-black/50 text-white px-2 py-0.5 rounded-full">{t}</span>
          ))}
        </div>
      </div>
      <div className="p-3">
        <h3 className={`font-bold text-sm leading-relaxed line-clamp-2 mb-2 ${dark ? "text-white" : "text-gray-900"}`}>{article.title}</h3>
        <p className={`text-xs leading-relaxed line-clamp-2 mb-3 ${dark ? "text-gray-400" : "text-gray-500"}`}>{article.excerpt}</p>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className={`text-xs font-semibold ${dark ? "text-[#00a651]" : "text-[#006C35]"}`}>{article.source}</span>
            <span className={`text-xs ${dark ? "text-gray-500" : "text-gray-400"}`}>•</span>
            <span className={`text-xs ${dark ? "text-gray-500" : "text-gray-400"}`}>{article.time}</span>
          </div>
          <div className="flex items-center gap-1">
            <span className={`text-xs ${dark ? "text-gray-500" : "text-gray-400"}`}>👁 {article.reads}</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function SmallNewsCard({ article, dark, onFavorite, isFav }: { article: typeof newsArticles[0]; dark: boolean; onFavorite: (id: number) => void; isFav: boolean }) {
  return (
    <div className={`flex gap-3 p-3 rounded-xl border ${dark ? "bg-[#161b22] border-gray-800" : "bg-white border-gray-100"} mb-2 shadow-sm`}>
      <img src={article.img} alt="" className="w-20 h-16 rounded-lg object-cover shrink-0 bg-gray-200" />
      <div className="flex-1 min-w-0">
        <h4 className={`text-xs font-bold line-clamp-2 leading-relaxed ${dark ? "text-white" : "text-gray-900"}`}>{article.title}</h4>
        <div className="flex items-center justify-between mt-1">
          <span className={`text-[10px] ${dark ? "text-[#00a651]" : "text-[#006C35]"} font-semibold`}>{article.source}</span>
          <span className={`text-[10px] ${dark ? "text-gray-500" : "text-gray-400"}`}>{article.time}</span>
        </div>
      </div>
      <button onClick={() => onFavorite(article.id)} className={`self-start text-sm ${isFav ? "text-[#006C35]" : dark ? "text-gray-500" : "text-gray-300"}`}>
        {isFav ? "♥" : "♡"}
      </button>
    </div>
  );
}

function CategoryPills({ cats, active, onSelect, dark }: { cats: { id: string; label: string }[]; active: string; onSelect: (id: string) => void; dark: boolean }) {
  return (
    <div className="flex gap-2 overflow-x-auto pb-2 px-4 scrollbar-hide" style={{ scrollbarWidth: "none" }}>
      {cats.map(c => (
        <button
          key={c.id}
          onClick={() => onSelect(c.id)}
          className={`shrink-0 px-4 py-1.5 rounded-full text-xs font-semibold transition-all ${active === c.id
            ? "bg-[#006C35] text-white shadow-md"
            : dark
              ? "bg-gray-800 text-gray-300 border border-gray-700"
              : "bg-white text-gray-600 border border-gray-200"
            }`}
        >
          {c.label}
        </button>
      ))}
    </div>
  );
}

function SearchBar({ dark, placeholder }: { dark: boolean; placeholder: string }) {
  const [q, setQ] = useState("");
  return (
    <div className={`mx-4 my-3 flex items-center gap-2 px-4 py-2.5 rounded-full border ${dark ? "bg-gray-800 border-gray-700 text-white" : "bg-gray-50 border-gray-200 text-gray-900"}`}>
      <span className={dark ? "text-gray-400" : "text-gray-400"}>🔍</span>
      <input
        value={q}
        onChange={e => setQ(e.target.value)}
        placeholder={placeholder}
        className="flex-1 bg-transparent text-sm outline-none placeholder-gray-400"
        dir="rtl"
      />
      {q && <button onClick={() => setQ("")} className="text-gray-400 text-xs">✕</button>}
    </div>
  );
}

// ─── Screens ─────────────────────────────────────────────────────────────────

function HomeScreen({ dark, favorites, onFavorite }: { dark: boolean; favorites: Set<number>; onFavorite: (id: number) => void }) {
  const [activeCategory, setActiveCategory] = useState<string>("all");
  const sections = [
    { id: "all", label: "الكل" },
    { id: "ksa", label: "🇸🇦 السعودية" },
    { id: "tech", label: "💻 تقنية" },
    { id: "sports", label: "⚽ رياضة" },
    { id: "economy", label: "💼 اقتصاد" },
  ];
  const featured = newsArticles[0];
  const rest = newsArticles.slice(1).filter(a => activeCategory === "all" || a.category === activeCategory);

  return (
    <div className="flex-1 overflow-y-auto">
      <SearchBar dark={dark} placeholder="ابحث في الأخبار..." />
      <BreakingTicker dark={dark} />

      {/* Featured */}
      <div className="px-4 pt-4 pb-2">
        <div className="relative rounded-2xl overflow-hidden shadow-lg">
          <img src={featured.img} alt={featured.title} className="w-full h-52 object-cover bg-gray-300" />
          <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />
          <div className="absolute bottom-0 right-0 left-0 p-4">
            <div className="flex gap-1 mb-2">
              {featured.tags.map(t => (
                <span key={t} className="text-[10px] bg-[#006C35] text-white px-2 py-0.5 rounded-full">{t}</span>
              ))}
            </div>
            <h2 className="text-white font-bold text-base leading-snug line-clamp-2">{featured.title}</h2>
            <div className="flex justify-between items-center mt-2">
              <span className="text-green-300 text-xs font-semibold">{featured.source}</span>
              <span className="text-gray-300 text-xs">{featured.time}</span>
            </div>
          </div>
          <button
            onClick={() => onFavorite(featured.id)}
            className={`absolute top-3 left-3 w-8 h-8 rounded-full flex items-center justify-center shadow-md ${favorites.has(featured.id) ? "bg-[#006C35] text-white" : "bg-white/80 text-gray-600"}`}
          >
            {favorites.has(featured.id) ? "♥" : "♡"}
          </button>
        </div>
      </div>

      <div className="mb-2">
        <CategoryPills cats={sections} active={activeCategory} onSelect={setActiveCategory} dark={dark} />
      </div>

      {/* Most Read */}
      <div className="px-4 mb-3">
        <div className={`flex items-center gap-2 mb-3`}>
          <div className="w-1 h-5 bg-[#006C35] rounded-full" />
          <h3 className={`font-bold text-sm ${dark ? "text-white" : "text-gray-900"}`}>الأكثر قراءة</h3>
        </div>
        {newsArticles.slice(0, 3).map((a, i) => (
          <div key={a.id} className={`flex gap-3 items-center py-2 border-b ${dark ? "border-gray-800" : "border-gray-100"}`}>
            <span className={`text-2xl font-black w-7 ${i === 0 ? "text-[#006C35]" : dark ? "text-gray-600" : "text-gray-300"}`}>{i + 1}</span>
            <div className="flex-1 min-w-0">
              <p className={`text-xs font-semibold line-clamp-2 ${dark ? "text-white" : "text-gray-900"}`}>{a.title}</p>
              <p className={`text-[10px] mt-0.5 ${dark ? "text-gray-500" : "text-gray-400"}`}>{a.reads} قراءة</p>
            </div>
          </div>
        ))}
      </div>

      {/* Latest */}
      <div className="px-4 mb-20">
        <div className="flex items-center gap-2 mb-3">
          <div className="w-1 h-5 bg-[#006C35] rounded-full" />
          <h3 className={`font-bold text-sm ${dark ? "text-white" : "text-gray-900"}`}>آخر الأخبار</h3>
        </div>
        {rest.length > 0 ? rest.map(a => (
          <SmallNewsCard key={a.id} article={a} dark={dark} onFavorite={onFavorite} isFav={favorites.has(a.id)} />
        )) : (
          <p className={`text-center py-8 text-sm ${dark ? "text-gray-500" : "text-gray-400"}`}>لا توجد أخبار في هذا القسم</p>
        )}
      </div>
    </div>
  );
}

function NewsScreen({ dark, favorites, onFavorite }: { dark: boolean; favorites: Set<number>; onFavorite: (id: number) => void }) {
  const [cat, setCat] = useState<NewsCategory>("all");
  const cats = [
    { id: "all", label: "الكل" }, { id: "ksa", label: "المملكة" },
    { id: "economy", label: "الاقتصاد" }, { id: "business", label: "الأعمال" },
    { id: "education", label: "التعليم" }, { id: "health", label: "الصحة" },
    { id: "society", label: "المجتمع" }, { id: "tourism", label: "السياحة" },
    { id: "vision2030", label: "رؤية ٢٠٣٠" },
  ];
  const filtered = newsArticles.filter(a => cat === "all" || a.category === cat);

  return (
    <div className="flex-1 overflow-y-auto">
      <SearchBar dark={dark} placeholder="ابحث في أخبار السعودية..." />
      <div className="mb-3">
        <CategoryPills cats={cats} active={cat} onSelect={v => setCat(v as NewsCategory)} dark={dark} />
      </div>
      <div className="px-4 mb-20">
        {filtered.length > 0 ? filtered.map(a => (
          <NewsCard key={a.id} article={a} dark={dark} onFavorite={onFavorite} isFav={favorites.has(a.id)} />
        )) : (
          <p className={`text-center py-12 text-sm ${dark ? "text-gray-500" : "text-gray-400"}`}>لا توجد أخبار في هذا التصنيف</p>
        )}
      </div>
    </div>
  );
}

function SportsScreen({ dark }: { dark: boolean }) {
  const [cat, setCat] = useState<SportsCategory>("all");
  const [view, setView] = useState<"matches" | "table" | "news">("matches");
  const cats = [
    { id: "all", label: "الكل" }, { id: "league", label: "دوري روشن" },
    { id: "clubs", label: "الأندية" }, { id: "players", label: "اللاعبون" },
    { id: "international", label: "دولي" },
  ];

  return (
    <div className="flex-1 overflow-y-auto">
      <div className="px-4 pt-3 flex gap-2 mb-3">
        <button onClick={() => setView("matches")} className={`flex-1 py-2 rounded-xl text-xs font-bold transition-all ${view === "matches" ? "bg-[#006C35] text-white" : dark ? "bg-gray-800 text-gray-400" : "bg-gray-100 text-gray-600"}`}>
          📅 المباريات
        </button>
        <button onClick={() => setView("table")} className={`flex-1 py-2 rounded-xl text-xs font-bold transition-all ${view === "table" ? "bg-[#006C35] text-white" : dark ? "bg-gray-800 text-gray-400" : "bg-gray-100 text-gray-600"}`}>
          📊 الترتيب
        </button>
        <button onClick={() => setView("news")} className={`flex-1 py-2 rounded-xl text-xs font-bold transition-all ${view === "news" ? "bg-[#006C35] text-white" : dark ? "bg-gray-800 text-gray-400" : "bg-gray-100 text-gray-600"}`}>
          📰 الأخبار
        </button>
      </div>

      {view === "matches" ? (
        <>
          <div className="mb-3">
            <CategoryPills cats={cats} active={cat} onSelect={v => setCat(v as SportsCategory)} dark={dark} />
          </div>
          <div className="px-4 mb-20 space-y-3">
            {matches.map(m => (
              <div key={m.id} className={`rounded-2xl p-4 border ${dark ? "bg-[#161b22] border-gray-800" : "bg-white border-gray-100"} shadow-sm`}>
                <div className="flex items-center justify-between mb-2">
                  <span className={`text-[10px] font-semibold px-2 py-0.5 rounded-full ${dark ? "bg-gray-800 text-gray-300" : "bg-gray-100 text-gray-600"}`}>{m.league}</span>
                  <span className={`text-[10px] px-2 py-0.5 rounded-full font-semibold ${m.status === "قادمة" ? "bg-blue-100 text-blue-700" : dark ? "bg-gray-700 text-gray-400" : "bg-green-50 text-green-700"}`}>
                    {m.status === "قادمة" ? `🕐 ${m.time} • ${m.date}` : `✅ ${m.date}`}
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex flex-col items-center gap-1 flex-1">
                    <span className="text-3xl">{m.homeLogo}</span>
                    <span className={`text-xs font-bold text-center ${dark ? "text-white" : "text-gray-900"}`}>{m.homeTeam}</span>
                  </div>
                  <div className="flex flex-col items-center px-4">
                    {m.status === "قادمة" ? (
                      <span className={`text-lg font-black ${dark ? "text-gray-400" : "text-gray-400"}`}>vs</span>
                    ) : (
                      <div className="flex items-center gap-2">
                        <span className={`text-2xl font-black ${dark ? "text-white" : "text-gray-900"}`}>{m.homeScore}</span>
                        <span className={`text-sm ${dark ? "text-gray-500" : "text-gray-400"}`}>-</span>
                        <span className={`text-2xl font-black ${dark ? "text-white" : "text-gray-900"}`}>{m.awayScore}</span>
                      </div>
                    )}
                  </div>
                  <div className="flex flex-col items-center gap-1 flex-1">
                    <span className="text-3xl">{m.awayLogo}</span>
                    <span className={`text-xs font-bold text-center ${dark ? "text-white" : "text-gray-900"}`}>{m.awayTeam}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </>
      ) : view === "news" ? (
        <div className="px-4 mb-20">
          {leagueNews.map(a => (
            <NewsCard key={a.id} article={a as typeof newsArticles[0]} dark={dark} onFavorite={() => {}} isFav={false} />
          ))}
        </div>
      ) : (
        <div className="px-4 mb-20">
          <div className={`rounded-2xl overflow-hidden border ${dark ? "border-gray-800" : "border-gray-100"} shadow-sm`}>
            <div className={`flex px-4 py-2 text-[10px] font-bold ${dark ? "bg-gray-800 text-gray-400" : "bg-[#006C35] text-white"}`}>
              <span className="w-6">#</span>
              <span className="flex-1">الفريق</span>
              <span className="w-6 text-center">ل</span>
              <span className="w-6 text-center">ت</span>
              <span className="w-6 text-center">ف</span>
              <span className="w-8 text-center">ن</span>
            </div>
            {leagueTable.map((row, i) => (
              <div key={row.pos} className={`flex items-center px-4 py-3 text-xs border-b ${dark ? "border-gray-800" : "border-gray-50"} ${i % 2 === 0 ? (dark ? "bg-[#161b22]" : "bg-white") : (dark ? "bg-gray-900" : "bg-gray-50/50")}`}>
                <span className={`w-6 font-black ${row.pos <= 3 ? "text-[#006C35]" : dark ? "text-gray-400" : "text-gray-500"}`}>{row.pos}</span>
                <div className="flex-1 flex items-center gap-1.5">
                  <span className="text-base">{row.logo}</span>
                  <span className={`font-semibold ${dark ? "text-white" : "text-gray-900"}`}>{row.team}</span>
                </div>
                <span className={`w-6 text-center ${dark ? "text-gray-400" : "text-gray-500"}`}>{row.l}</span>
                <span className={`w-6 text-center ${dark ? "text-gray-400" : "text-gray-500"}`}>{row.d}</span>
                <span className={`w-6 text-center ${dark ? "text-gray-400" : "text-gray-500"}`}>{row.w}</span>
                <span className={`w-8 text-center font-black ${dark ? "text-[#00a651]" : "text-[#006C35]"}`}>{row.pts}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

function JobsScreen({ dark }: { dark: boolean }) {
  const [saved, setSaved] = useState(new Set<number>());
  const [cityFilter, setCityFilter] = useState("all");
  const [search, setSearch] = useState("");
  const cityFilters = [{ id: "all", label: "كل المدن" }, { id: "riyadh", label: "الرياض" }, { id: "jeddah", label: "جدة" }, { id: "dammam", label: "الدمام" }, { id: "remote", label: "عن بُعد" }];

  const filtered = jobs.filter(j => {
    const matchesSearch = j.title.includes(search) || j.company.includes(search);
    const matchesCity = cityFilter === "all" ||
      (cityFilter === "riyadh" && j.city === "الرياض") ||
      (cityFilter === "jeddah" && j.city === "جدة") ||
      (cityFilter === "dammam" && j.city === "الدمام") ||
      (cityFilter === "remote" && j.type === "عن بُعد");
    return matchesSearch && matchesCity;
  });

  return (
    <div className="flex-1 overflow-y-auto">
      <div className="px-4 pt-3">
        <div className={`flex items-center gap-2 px-4 py-2.5 rounded-full border ${dark ? "bg-gray-800 border-gray-700" : "bg-gray-50 border-gray-200"} mb-3`}>
          <span className="text-gray-400">🔍</span>
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="ابحث عن وظيفة أو شركة..." className={`flex-1 bg-transparent text-sm outline-none ${dark ? "text-white placeholder-gray-500" : "text-gray-900 placeholder-gray-400"}`} dir="rtl" />
        </div>
      </div>
      <div className="mb-3">
        <CategoryPills cats={cityFilters} active={cityFilter} onSelect={setCityFilter} dark={dark} />
      </div>
      <div className="px-4 mb-20 space-y-3">
        <p className={`text-xs mb-2 ${dark ? "text-gray-500" : "text-gray-400"}`}>{filtered.length} وظيفة متاحة</p>
        {filtered.map(job => (
          <div key={job.id} className={`rounded-2xl p-4 border ${dark ? "bg-[#161b22] border-gray-800" : "bg-white border-gray-100"} shadow-sm`}>
            <div className="flex items-start justify-between mb-2">
              <div className="flex items-center gap-3">
                <div className={`w-11 h-11 rounded-xl flex items-center justify-center text-2xl ${dark ? "bg-gray-800" : "bg-gray-50"}`}>{job.logo}</div>
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className={`font-bold text-sm ${dark ? "text-white" : "text-gray-900"}`}>{job.title}</h3>
                    {job.urgent && <span className="text-[9px] bg-red-100 text-red-600 px-1.5 py-0.5 rounded-full font-bold">عاجل</span>}
                  </div>
                  <p className={`text-xs ${dark ? "text-[#00a651]" : "text-[#006C35]"} font-semibold`}>{job.company}</p>
                </div>
              </div>
              <button onClick={() => setSaved(s => { const n = new Set(s); n.has(job.id) ? n.delete(job.id) : n.add(job.id); return n; })} className={`text-lg ${saved.has(job.id) ? "text-[#006C35]" : dark ? "text-gray-600" : "text-gray-300"}`}>
                {saved.has(job.id) ? "🔖" : "🔖"}
              </button>
            </div>
            <div className="flex flex-wrap gap-1.5 mb-3">
              <span className={`text-[10px] px-2 py-1 rounded-lg font-medium ${dark ? "bg-gray-800 text-gray-300" : "bg-gray-50 text-gray-600"}`}>📍 {job.city}</span>
              <span className={`text-[10px] px-2 py-1 rounded-lg font-medium ${dark ? "bg-blue-900/30 text-blue-300" : "bg-blue-50 text-blue-700"}`}>{job.type}</span>
              <span className={`text-[10px] px-2 py-1 rounded-lg font-medium ${dark ? "bg-gray-800 text-gray-300" : "bg-gray-50 text-gray-600"}`}>⏱ {job.experience}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className={`text-xs font-bold ${dark ? "text-[#00a651]" : "text-[#006C35]"}`}>{job.salary}</span>
              <div className="flex items-center gap-2">
                <span className={`text-[10px] ${dark ? "text-gray-500" : "text-gray-400"}`}>{job.date}</span>
                <button className="bg-[#006C35] text-white text-[10px] font-bold px-3 py-1.5 rounded-full">تقدم الآن</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function TechScreen({ dark, favorites, onFavorite }: { dark: boolean; favorites: Set<number>; onFavorite: (id: number) => void }) {
  const [cat, setCat] = useState<TechCategory>("all");
  const cats = [
    { id: "all", label: "الكل" }, { id: "ai", label: "🤖 ذكاء اصطناعي" },
    { id: "phones", label: "📱 هواتف" }, { id: "apps", label: "📲 تطبيقات" },
    { id: "games", label: "🎮 ألعاب" }, { id: "security", label: "🔒 أمن سيبراني" },
    { id: "companies", label: "🏢 شركات" },
  ];
  const filtered = techArticles.filter(a => cat === "all" || a.category === cat);

  return (
    <div className="flex-1 overflow-y-auto">
      <SearchBar dark={dark} placeholder="ابحث في أخبار التقنية..." />
      <div className="mb-3">
        <CategoryPills cats={cats} active={cat} onSelect={v => setCat(v as TechCategory)} dark={dark} />
      </div>
      <div className="px-4 mb-20">
        {filtered.map(a => (
          <NewsCard key={a.id} article={a as typeof newsArticles[0]} dark={dark} onFavorite={onFavorite} isFav={favorites.has(a.id)} />
        ))}
      </div>
    </div>
  );
}

function DirectoryScreen({ dark }: { dark: boolean }) {
  const [search, setSearch] = useState("");
  const [cat, setCat] = useState("all");
  const [selected, setSelected] = useState<typeof directory[0] | null>(null);
  const cats = [
    { id: "all", label: "الكل" }, { id: "مستشفيات", label: "🏥 مستشفيات" },
    { id: "حكومي", label: "🏛 حكومي" }, { id: "مطاعم", label: "🍽 مطاعم" },
    { id: "اتصالات", label: "📡 اتصالات" }, { id: "طيران", label: "✈️ طيران" },
  ];
  const filtered = directory.filter(d =>
    (cat === "all" || d.cat === cat) &&
    (d.name.includes(search) || d.city.includes(search) || d.phone.includes(search))
  );

  if (selected) {
    return (
      <div className="flex-1 overflow-y-auto slide-in">
        <div className={`px-4 py-4 ${dark ? "bg-[#161b22]" : "bg-white"} border-b ${dark ? "border-gray-800" : "border-gray-100"}`}>
          <button onClick={() => setSelected(null)} className={`text-sm font-semibold ${dark ? "text-[#00a651]" : "text-[#006C35]"} mb-3`}>‹ العودة للدليل</button>
          <div className="flex items-center gap-3">
            <div className={`w-14 h-14 rounded-2xl flex items-center justify-center text-2xl ${dark ? "bg-gray-800" : "bg-green-50"}`}>
              {selected.cat === "مستشفيات" ? "🏥" : selected.cat === "حكومي" ? "🏛" : selected.cat === "مطاعم" ? "🍽" : selected.cat === "اتصالات" ? "📡" : "✈️"}
            </div>
            <div>
              <h2 className={`font-bold text-base ${dark ? "text-white" : "text-gray-900"}`}>{selected.name}</h2>
              <span className={`text-xs ${dark ? "text-[#00a651]" : "text-[#006C35]"} font-semibold`}>{selected.cat}</span>
            </div>
          </div>
        </div>
        <div className="px-4 pt-4 space-y-3 mb-20">
          <div className={`p-4 rounded-2xl ${dark ? "bg-[#161b22] border border-gray-800" : "bg-white border border-gray-100"}`}>
            <div className="space-y-3">
              <div className="flex items-center gap-3">
                <span className="text-lg">📞</span>
                <div>
                  <p className={`text-xs ${dark ? "text-gray-500" : "text-gray-400"}`}>رقم الهاتف</p>
                  <p className={`font-bold ${dark ? "text-white" : "text-gray-900"}`} dir="ltr">{selected.phone}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-lg">📍</span>
                <div>
                  <p className={`text-xs ${dark ? "text-gray-500" : "text-gray-400"}`}>العنوان</p>
                  <p className={`text-sm font-medium ${dark ? "text-white" : "text-gray-900"}`}>{selected.address}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-lg">⭐</span>
                <div>
                  <p className={`text-xs ${dark ? "text-gray-500" : "text-gray-400"}`}>التقييم</p>
                  <p className={`font-bold ${dark ? "text-white" : "text-gray-900"}`}>{selected.rating} / ٥</p>
                </div>
              </div>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <a href={`tel:${selected.phone}`} className="bg-[#006C35] text-white py-3 rounded-2xl text-sm font-bold text-center flex items-center justify-center gap-2">
              <span>📞</span> اتصال
            </a>
            <button className={`py-3 rounded-2xl text-sm font-bold flex items-center justify-center gap-2 border ${dark ? "border-gray-700 text-gray-300" : "border-gray-200 text-gray-700"}`}>
              <span>🗺</span> الموقع
            </button>
          </div>
          <button className={`w-full py-3 rounded-2xl text-sm font-bold flex items-center justify-center gap-2 border ${dark ? "border-gray-700 text-gray-300" : "border-gray-200 text-gray-700"}`}>
            <span>💬</span> واتساب
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="flex-1 overflow-y-auto">
      <div className="px-4 pt-3">
        <div className={`flex items-center gap-2 px-4 py-2.5 rounded-full border ${dark ? "bg-gray-800 border-gray-700" : "bg-gray-50 border-gray-200"} mb-3`}>
          <span className="text-gray-400">🔍</span>
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="ابحث بالاسم أو رقم الهاتف..." className={`flex-1 bg-transparent text-sm outline-none ${dark ? "text-white placeholder-gray-500" : "text-gray-900 placeholder-gray-400"}`} dir="rtl" />
        </div>
      </div>
      <div className="mb-3">
        <CategoryPills cats={cats} active={cat} onSelect={setCat} dark={dark} />
      </div>
      <div className="px-4 mb-20 space-y-2">
        {filtered.map(d => (
          <button key={d.id} onClick={() => setSelected(d)} className={`w-full flex items-center gap-3 p-3 rounded-2xl border text-right ${dark ? "bg-[#161b22] border-gray-800" : "bg-white border-gray-100"} shadow-sm`}>
            <div className={`w-11 h-11 rounded-xl flex items-center justify-center text-xl shrink-0 ${dark ? "bg-gray-800" : "bg-green-50"}`}>
              {d.cat === "مستشفيات" ? "🏥" : d.cat === "حكومي" ? "🏛" : d.cat === "مطاعم" ? "🍽" : d.cat === "اتصالات" ? "📡" : "✈️"}
            </div>
            <div className="flex-1 min-w-0">
              <p className={`font-bold text-sm ${dark ? "text-white" : "text-gray-900"}`}>{d.name}</p>
              <div className="flex items-center gap-2">
                <span className={`text-xs ${dark ? "text-[#00a651]" : "text-[#006C35]"}`}>{d.cat}</span>
                <span className={`text-xs ${dark ? "text-gray-500" : "text-gray-400"}`}>• {d.city}</span>
              </div>
            </div>
            <div className="flex flex-col items-end gap-1">
              <span className="text-yellow-500 text-xs">⭐ {d.rating}</span>
              <span className={`text-[10px] ${dark ? "text-gray-500" : "text-gray-400"}`} dir="ltr">{d.phone}</span>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}

function PrayerScreen({ dark }: { dark: boolean }) {
  const [city, setCity] = useState("الرياض");
  const [showCities, setShowCities] = useState(false);
  const nextIdx = 4;
  const [angle, setAngle] = useState(137);

  useEffect(() => {
    const t = setInterval(() => setAngle(a => (a + 0.5) % 360), 100);
    return () => clearInterval(t);
  }, []);

  return (
    <div className="flex-1 overflow-y-auto mb-20">
      {/* Header */}
      <div className={`mx-4 mt-4 p-4 rounded-2xl bg-[#006C35] text-white`}>
        <div className="flex items-center justify-between mb-1">
          <div>
            <p className="text-xs opacity-80">{prayerTimes.date}</p>
            <p className="text-xs opacity-70">{prayerTimes.hijri}</p>
          </div>
          <button onClick={() => setShowCities(!showCities)} className="flex items-center gap-1 bg-white/20 px-3 py-1.5 rounded-full text-xs font-semibold">
            📍 {city} ▾
          </button>
        </div>
        {showCities && (
          <div className={`mt-2 grid grid-cols-2 gap-1 rounded-xl overflow-hidden ${dark ? "bg-gray-900" : "bg-white/10"}`}>
            {cities.map(c => (
              <button key={c} onClick={() => { setCity(c); setShowCities(false); }} className={`py-2 text-xs font-medium text-white/90 hover:bg-white/20 ${c === city ? "bg-white/30 font-bold" : ""}`}>{c}</button>
            ))}
          </div>
        )}
        <div className="mt-3 flex items-center justify-between">
          <div>
            <p className="text-xs opacity-70">الصلاة القادمة</p>
            <p className="text-xl font-black">{prayerTimes.next.name}</p>
            <p className="text-sm opacity-90" dir="ltr">{prayerTimes.next.remaining}</p>
          </div>
          <div className="text-4xl">🕌</div>
        </div>
      </div>

      {/* Prayer times grid */}
      <div className="px-4 mt-4">
        <div className="grid grid-cols-2 gap-2">
          {prayerTimes.times.map((p, i) => (
            <div key={p.name} className={`p-3 rounded-2xl border ${i === nextIdx ? (dark ? "border-[#006C35] bg-[#006C35]/10" : "border-[#006C35] bg-green-50") : (dark ? "bg-[#161b22] border-gray-800" : "bg-white border-gray-100")} flex items-center gap-3`}>
              <span className="text-xl">{p.icon}</span>
              <div>
                <p className={`text-xs ${dark ? "text-gray-400" : "text-gray-500"}`}>{p.name}</p>
                <p className={`font-bold text-sm ${i === nextIdx ? "text-[#006C35]" : dark ? "text-white" : "text-gray-900"}`} dir="ltr">{p.time}</p>
              </div>
              {i === nextIdx && <span className="mr-auto text-[10px] bg-[#006C35] text-white px-1.5 py-0.5 rounded-full">التالية</span>}
            </div>
          ))}
        </div>
      </div>

      {/* Qibla compass */}
      <div className="px-4 mt-4 mb-6">
        <div className={`p-4 rounded-2xl border ${dark ? "bg-[#161b22] border-gray-800" : "bg-white border-gray-100"} shadow-sm`}>
          <div className="flex items-center gap-2 mb-4">
            <div className="w-1 h-5 bg-[#006C35] rounded-full" />
            <h3 className={`font-bold text-sm ${dark ? "text-white" : "text-gray-900"}`}>بوصلة القبلة</h3>
          </div>
          <div className="flex flex-col items-center">
            <div className="relative w-44 h-44">
              <div className={`w-full h-full rounded-full border-4 ${dark ? "border-gray-700" : "border-gray-200"} flex items-center justify-center`}>
                <div className={`w-32 h-32 rounded-full border-2 ${dark ? "border-gray-600" : "border-gray-100"} flex items-center justify-center`}>
                  <div
                    className="w-0 h-0 transition-transform duration-100"
                    style={{ transform: `rotate(${angle}deg)` }}
                  >
                    <div className="flex flex-col items-center" style={{ marginTop: "-48px" }}>
                      <div className="text-2xl">🕋</div>
                      <div className="w-0.5 h-12 bg-[#006C35]" />
                      <div className="w-2 h-2 bg-red-500 rounded-full" />
                    </div>
                  </div>
                </div>
              </div>
              {["ش", "ج", "غ", "ق"].map((dir, i) => {
                const positions = ["top-1 left-1/2 -translate-x-1/2", "left-1 top-1/2 -translate-y-1/2", "bottom-1 left-1/2 -translate-x-1/2", "right-1 top-1/2 -translate-y-1/2"];
                return <span key={dir} className={`absolute ${positions[i]} text-xs font-bold ${dark ? "text-gray-400" : "text-gray-400"}`}>{dir}</span>;
              })}
            </div>
            <p className={`text-xs mt-3 ${dark ? "text-gray-400" : "text-gray-500"}`}>اتجاه القبلة: {angle.toFixed(0)}° شمالًا</p>
          </div>
        </div>
      </div>
    </div>
  );
}

function FavoritesScreen({ dark, favorites, allArticles, onFavorite }: { dark: boolean; favorites: Set<number>; allArticles: typeof newsArticles; onFavorite: (id: number) => void }) {
  const favs = allArticles.filter(a => favorites.has(a.id));
  return (
    <div className="flex-1 overflow-y-auto">
      <div className="px-4 pt-4 mb-20">
        {favs.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 gap-4">
            <span className="text-6xl">♡</span>
            <p className={`text-center text-sm ${dark ? "text-gray-500" : "text-gray-400"}`}>لم تحفظ أي مقال بعد<br />اضغط على ♡ في أي خبر لحفظه هنا</p>
          </div>
        ) : (
          favs.map(a => <NewsCard key={a.id} article={a} dark={dark} onFavorite={onFavorite} isFav={true} />)
        )}
      </div>
    </div>
  );
}

function NotificationsScreen({ dark }: { dark: boolean }) {
  const notifications = [
    { id: 1, icon: "🔴", title: "خبر عاجل", body: "مجلس الوزراء يعقد جلسته", time: "منذ ٥ دق", read: false },
    { id: 2, icon: "⚽", title: "الرياضة", body: "الهلال يفوز على الاتحاد ٣-١", time: "منذ ٣٠ دق", read: false },
    { id: 3, icon: "💼", title: "وظيفة جديدة", body: "أرامكو تطلب مهندس برمجيات", time: "منذ ساعة", read: true },
    { id: 4, icon: "🤖", title: "أخبار التقنية", body: "سدايا تطلق نموذج اللغة العربي", time: "منذ ٢ س", read: true },
    { id: 5, icon: "🕌", title: "مواقيت الصلاة", body: "حان وقت صلاة المغرب", time: "منذ ٣ س", read: true },
  ];
  return (
    <div className="flex-1 overflow-y-auto">
      <div className="px-4 pt-4 mb-20 space-y-2">
        {notifications.map(n => (
          <div key={n.id} className={`flex gap-3 p-3 rounded-2xl border ${n.read ? (dark ? "bg-[#161b22] border-gray-800" : "bg-white border-gray-100") : (dark ? "bg-[#006C35]/10 border-[#006C35]/30" : "bg-green-50 border-green-100")}`}>
            <span className="text-2xl">{n.icon}</span>
            <div className="flex-1">
              <div className="flex justify-between">
                <span className={`text-xs font-bold ${dark ? "text-white" : "text-gray-900"}`}>{n.title}</span>
                <span className={`text-[10px] ${dark ? "text-gray-500" : "text-gray-400"}`}>{n.time}</span>
              </div>
              <p className={`text-xs mt-0.5 ${dark ? "text-gray-400" : "text-gray-600"}`}>{n.body}</p>
            </div>
            {!n.read && <div className="w-2 h-2 bg-[#006C35] rounded-full mt-1 shrink-0" />}
          </div>
        ))}
      </div>
    </div>
  );
}

function SettingsScreen({ dark, onToggleDark }: { dark: boolean; onToggleDark: () => void }) {
  const settings = [
    { section: "المظهر", items: [{ icon: "🌙", label: "الوضع الليلي", toggle: true, value: dark, action: onToggleDark }] },
    { section: "الإشعارات", items: [{ icon: "🔔", label: "إشعارات الأخبار العاجلة", toggle: true, value: true, action: () => { } }, { icon: "⚽", label: "إشعارات الرياضة", toggle: true, value: false, action: () => { } }, { icon: "🕌", label: "إشعارات مواقيت الصلاة", toggle: true, value: true, action: () => { } }] },
    { section: "عام", items: [{ icon: "🌐", label: "اللغة: العربية", toggle: false, value: false, action: () => { } }, { icon: "📍", label: "الموقع الحالي: الرياض", toggle: false, value: false, action: () => { } }, { icon: "ℹ️", label: "عن التطبيق v١.٠.٠", toggle: false, value: false, action: () => { } }] },
  ];

  return (
    <div className="flex-1 overflow-y-auto">
      <div className="px-4 pt-4 mb-20 space-y-4">
        {/* Profile */}
        <div className={`p-4 rounded-2xl border ${dark ? "bg-[#161b22] border-gray-800" : "bg-white border-gray-100"} flex items-center gap-3`}>
          <div className="w-14 h-14 bg-[#006C35] rounded-full flex items-center justify-center text-white text-2xl font-bold">م</div>
          <div>
            <p className={`font-bold ${dark ? "text-white" : "text-gray-900"}`}>مستخدم أخبار السعودية</p>
            <p className={`text-xs ${dark ? "text-gray-400" : "text-gray-500"}`}>مفضلتك • ٣ مقالات محفوظة</p>
          </div>
        </div>

        {settings.map(s => (
          <div key={s.section}>
            <p className={`text-xs font-bold mb-2 px-1 ${dark ? "text-gray-500" : "text-gray-400"}`}>{s.section}</p>
            <div className={`rounded-2xl border overflow-hidden ${dark ? "border-gray-800" : "border-gray-100"}`}>
              {s.items.map((item, i) => (
                <div key={item.label} className={`flex items-center justify-between p-4 ${dark ? "bg-[#161b22]" : "bg-white"} ${i < s.items.length - 1 ? `border-b ${dark ? "border-gray-800" : "border-gray-50"}` : ""}`}>
                  <div className="flex items-center gap-3">
                    <span className="text-lg">{item.icon}</span>
                    <span className={`text-sm ${dark ? "text-white" : "text-gray-900"}`}>{item.label}</span>
                  </div>
                  {item.toggle && (
                    <button onClick={item.action} className={`w-11 h-6 rounded-full transition-all ${item.value ? "bg-[#006C35]" : dark ? "bg-gray-700" : "bg-gray-200"} flex items-center px-0.5`}>
                      <div className={`w-5 h-5 bg-white rounded-full shadow transition-transform ${item.value ? "translate-x-5" : "translate-x-0"}`} />
                    </button>
                  )}
                  {!item.toggle && <span className={`text-xs ${dark ? "text-gray-500" : "text-gray-400"}`}>›</span>}
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function MoreMenu({ dark, onSelect, active }: { dark: boolean; onSelect: (s: MoreSection) => void; active: MoreSection | null }) {
  const items = [
    { id: "tech" as MoreSection, icon: "💻", label: "التكنولوجيا", desc: "أخبار تقنية وذكاء اصطناعي" },
    { id: "directory" as MoreSection, icon: "📞", label: "دليل الهاتف السعودي", desc: "ابحث عن أرقام الشركات والجهات" },
    { id: "prayer" as MoreSection, icon: "🕌", label: "مواقيت الصلاة والقبلة", desc: "أوقات الصلاة وبوصلة القبلة" },
    { id: "favorites" as MoreSection, icon: "♥", label: "المفضلة", desc: "الأخبار المحفوظة" },
    { id: "notifications" as MoreSection, icon: "🔔", label: "الإشعارات", desc: "كل الإشعارات" },
    { id: "settings" as MoreSection, icon: "⚙️", label: "الإعدادات", desc: "تخصيص التطبيق" },
  ];
  return (
    <div className="flex-1 overflow-y-auto">
      <div className="px-4 pt-4 mb-20 space-y-2">
        {items.map(item => (
          <button key={item.id} onClick={() => onSelect(item.id)} className={`w-full flex items-center gap-3 p-4 rounded-2xl border text-right transition-all ${active === item.id ? (dark ? "border-[#006C35] bg-[#006C35]/10" : "border-[#006C35] bg-green-50") : (dark ? "bg-[#161b22] border-gray-800 hover:border-gray-700" : "bg-white border-gray-100 hover:border-gray-200")} shadow-sm`}>
            <div className={`w-11 h-11 rounded-xl flex items-center justify-center text-2xl shrink-0 ${dark ? "bg-gray-800" : "bg-gray-50"}`}>{item.icon}</div>
            <div className="flex-1 min-w-0">
              <p className={`font-bold text-sm ${dark ? "text-white" : "text-gray-900"}`}>{item.label}</p>
              <p className={`text-xs ${dark ? "text-gray-500" : "text-gray-400"}`}>{item.desc}</p>
            </div>
            <span className={`text-lg ${dark ? "text-gray-600" : "text-gray-300"}`}>›</span>
          </button>
        ))}
      </div>
    </div>
  );
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
function BottomNav({ active, onSelect, dark }: { active: Tab; onSelect: (t: Tab) => void; dark: boolean }) {
  const tabs = [
    { id: "home" as Tab, icon: "🏠", label: "الرئيسية" },
    { id: "news" as Tab, icon: "📞", label: "دليل الهاتف" },
    { id: "sports" as Tab, icon: "⚽", label: "دوري روشن" },
    { id: "jobs" as Tab, icon: "💼", label: "الوظائف" },
    { id: "more" as Tab, icon: "☰", label: "المزيد" },
  ];
  return (
    <div className={`border-t ${dark ? "bg-[#161b22] border-gray-800" : "bg-white border-gray-100"} flex items-center`} style={{ paddingBottom: "env(safe-area-inset-bottom, 8px)" }}>
      {tabs.map(t => (
        <button key={t.id} onClick={() => onSelect(t.id)} className={`flex-1 flex flex-col items-center py-2 gap-0.5 transition-all`}>
          <span className={`text-lg transition-transform ${active === t.id ? "scale-110" : "scale-100"}`}>{t.icon}</span>
          <span className={`text-[9px] font-semibold ${active === t.id ? "text-[#006C35]" : dark ? "text-gray-500" : "text-gray-400"}`}>{t.label}</span>
          {active === t.id && <div className="w-1 h-1 bg-[#006C35] rounded-full" />}
        </button>
      ))}
    </div>
  );
}

// ─── Main App ─────────────────────────────────────────────────────────────────
export default function App() {
  const [dark, setDark] = useState(false);
  const [tab, setTab] = useState<Tab>("home");
  const [moreSection, setMoreSection] = useState<MoreSection | null>(null);
  const [favorites, setFavorites] = useState(new Set<number>());

  const allArticles = [...newsArticles, ...techArticles] as typeof newsArticles;

  const toggleFavorite = (id: number) => {
    setFavorites(s => {
      const n = new Set(s);
      n.has(id) ? n.delete(id) : n.add(id);
      return n;
    });
  };

  const handleMoreSelect = (s: MoreSection) => setMoreSection(s);
  const handleTabSelect = (t: Tab) => {
    setTab(t);
    if (t !== "more") setMoreSection(null);
  };

  const getHeaderTitle = () => {
    if (tab === "home") return "أخبار السعودية";
    if (tab === "news") return "📞 دليل الهاتف السعودي";
    if (tab === "sports") return "⚽ دوري روشن";
    if (tab === "jobs") return "💼 الوظائف";
    if (tab === "more" && moreSection === "tech") return "💻 التكنولوجيا";
    if (tab === "more" && moreSection === "directory") return "📞 دليل الهاتف";
    if (tab === "more" && moreSection === "prayer") return "🕌 الصلاة والقبلة";
    if (tab === "more" && moreSection === "favorites") return "♥ المفضلة";
    if (tab === "more" && moreSection === "notifications") return "🔔 الإشعارات";
    if (tab === "more" && moreSection === "settings") return "⚙️ الإعدادات";
    return "المزيد";
  };

  return (
    <div className={`size-full flex items-center justify-center ${dark ? "bg-gray-950" : "bg-gray-200"}`}>
      {/* Phone frame */}
      <div
        className={`relative flex flex-col overflow-hidden shadow-2xl ${dark ? "bg-[#0d1117]" : "bg-[#f8f9fa]"}`}
        style={{
          width: "min(100%, 390px)",
          height: "min(100%, 844px)",
          borderRadius: "clamp(0px, 4vw, 44px)",
          border: dark ? "1px solid #30363d" : "1px solid #d0d0d0",
        }}
      >
        <StatusBar dark={dark} />

        {/* Header */}
        <AppHeader
          title={getHeaderTitle()}
          dark={dark}
          showBack={tab === "more" && moreSection !== null}
          onBack={() => setMoreSection(null)}
        />

        {/* Content */}
        <div className="flex-1 overflow-hidden flex flex-col">
          {tab === "home" && <HomeScreen dark={dark} favorites={favorites} onFavorite={toggleFavorite} />}
          {tab === "news" && <DirectoryScreen dark={dark} />}
          {tab === "sports" && <SportsScreen dark={dark} />}
          {tab === "jobs" && <JobsScreen dark={dark} />}
          {tab === "more" && !moreSection && <MoreMenu dark={dark} onSelect={handleMoreSelect} active={moreSection} />}
          {tab === "more" && moreSection === "tech" && <TechScreen dark={dark} favorites={favorites} onFavorite={toggleFavorite} />}
          {tab === "more" && moreSection === "directory" && <DirectoryScreen dark={dark} />}
          {tab === "more" && moreSection === "prayer" && <PrayerScreen dark={dark} />}
          {tab === "more" && moreSection === "favorites" && <FavoritesScreen dark={dark} favorites={favorites} allArticles={allArticles} onFavorite={toggleFavorite} />}
          {tab === "more" && moreSection === "notifications" && <NotificationsScreen dark={dark} />}
          {tab === "more" && moreSection === "settings" && <SettingsScreen dark={dark} onToggleDark={() => setDark(d => !d)} />}
        </div>

        {/* Bottom Nav */}
        <BottomNav active={tab} onSelect={handleTabSelect} dark={dark} />
      </div>
    </div>
  );
}
