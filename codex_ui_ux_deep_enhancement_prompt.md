# 🎨 Codex Prompt — UI/UX Deep Enhancement (Maximum Level)

> ركّز هذه المهمة على الـ UI/UX فقط. لا تلمس الـ Business logic أو الـ Architecture إلا إذا كان تعديلها ضروريًا لتنفيذ تحسين واجهة (مثال: فصل Widget عن منطقه).

---

## 0) قبل البدء — Context Loading

1. اقرأ `rules.md` بالكامل وطبّق أي قواعد Code style/Naming/Structure واردة فيه على كل ملف UI تلمسه.
2. اعمل جرد كامل (Inventory) لكل الشاشات (Pages) والـ Widgets المشتركة (Shared/Common widgets) الموجودة حاليًا في `presentation/`.
3. لكل شاشة، سجّل تقييمًا أوليًا (قبل التعديل) يوضح: المشاكل البصرية، مشاكل الـ Layout، التناسق مع باقي الشاشات، وحالة الـ States (Loading/Empty/Error) إن وُجدت.

**لا تبدأ التعديل قبل إخراج هذا التقييم الأولي.**

---

## 1) بناء Design System موحّد أولاً

قبل تعديل أي شاشة فردية، أنشئ/طوّر طبقة Design System مركزية في `core/theme/` تشمل:

- **Color System**: `ColorScheme.fromSeed` مضبوط لكل من Light/Dark، + ألوان دلالية إضافية (success, warning, danger, info) كـ Theme extension.
- **Typography Scale**: نظام خطوط متسق (Display/Headline/Title/Body/Label) عبر `TextTheme`، بدل استخدام `TextStyle` يدوي متكرر في كل شاشة.
- **Spacing System**: قيم ثابتة موحّدة (مثلاً 4/8/12/16/24/32) في class واحد (`AppSpacing`) بدل أرقام Hardcoded متفرقة.
- **Radius & Elevation System**: قيم موحّدة لـ `BorderRadius` و`Shadow/Elevation` عبر كل الـ Cards/Buttons/Sheets.
- **Iconography**: توحيد مصدر الأيقونات (Material Symbols أو مكتبة واحدة) وحجم موحّد حسب السياق.
- كل شاشة تُعدَّل لاحقًا يجب أن تستهلك هذا النظام حصريًا، بدون أي قيمة Hardcoded جديدة.

استخدم **Skill: `Flutter Fix Layout Issues`** أثناء هذه المرحلة لضمان أن أي إعادة بناء لا تكسر الـ layout.

---

## 2) الهيكل البصري (Slivers + Visual Hierarchy)

- حوّل كل شاشة بها Scroll طويل أو مركّب (Header + List + Sections) إلى `CustomScrollView` مع:
  - `SliverAppBar` (مع `pinned`/`floating`/`snap` حسب سياق كل شاشة، و`flexibleSpace` لعناصر ديناميكية مثل صورة أو إحصائيات).
  - `SliverList`/`SliverGrid` بدل `ListView`/`GridView` العادية داخل Column.
  - `SliverToBoxAdapter` للعناصر الثابتة بين الأقسام.
  - `SliverPersistentHeader` لأي Tabs أو Filters تحتاج تثبيت أثناء الscroll.
- أعد ترتيب العناصر داخل كل شاشة حسب أولوية بصرية واضحة (أهم معلومة أولاً)، وقلّل التزاحم البصري (Visual clutter) عبر تجميع العناصر في مجموعات منطقية (Cards/Sections) بفواصل واضحة.
- تأكد أن كل شاشة لها **نقطة تركيز واحدة (Focal point)** واضحة بدل توزيع الاهتمام على عناصر متعددة بنفس الوزن البصري.

استخدم **Skill: `Flutter Build Responsive Layout`** لضمان أن هذا الهيكل يتكيف بشكل سليم مع أحجام الشاشات المختلفة (`LayoutBuilder`, `MediaQuery`, breakpoints).

---

## 3) الحالات التفاعلية والـ States

لكل شاشة تعرض بيانات، تأكد من وجود تصميم مخصص (وليس Placeholder افتراضي) لكل حالة:

- **Loading**: استخدم Skeleton loaders / Shimmer بدل `CircularProgressIndicator` وحيد في المنتصف حيثما كان مناسبًا لطبيعة المحتوى.
- **Empty State**: رسمة/أيقونة + نص توضيحي + Call-to-action واضح (مثال: "لا توجد معاملات بعد، أضف أول معاملة").
- **Error State**: رسالة خطأ مفهومة بلغة المستخدم + زر إعادة المحاولة، بدون تفاصيل تقنية خام.
- **Success feedback**: SnackBar/Toast/Dialog متسق التصميم عبر كل التطبيق لأي عملية ناجحة (حفظ، حذف، تعديل).

---

## 4) الحركة والتفاعل (Motion & Micro-interactions)

- أضف Transitions سلسة بين الشاشات (`PageRouteBuilder` مخصص أو Transitions المدمجة في go_router) بدل الانتقال الفجائي الافتراضي.
- أضف Micro-interactions خفيفة وذات معنى:
  - Animated feedback عند الضغط على الأزرار المهمة (Scale/Opacity بسيطة).
  - `AnimatedSwitcher`/`AnimatedContainer`/`Hero` عند تغيّر المحتوى أو الانتقال بين تفاصيل عنصر وقائمته.
  - Animated counters/charts عند تحميل بيانات رقمية (خصوصًا لو المشروع يستخدم `fl_chart`، حسّن الـ Animation curves والـ tooltips الخاصة بالـ charts).
- لا تُفرط في الحركة — كل Animation يجب أن يخدم الفهم أو يعطي Feedback، وليس زخرفة فقط. احترم `MediaQuery.disableAnimations` لدعم إمكانية الوصول.

---

## 5) الاتساق عبر التطبيق (Consistency Pass)

- مرّ على كل الأزرار (Primary/Secondary/Text/Icon buttons) ووحّد الشكل والحجم والسلوك حسب الأهمية (زر أساسي واحد بارز لكل شاشة كحد أقصى).
- مرّ على كل الـ Forms ووحّد شكل الحقول (`TextFormField` styling)، رسائل الـ Validation، ومكان ظهورها.
- مرّ على كل الـ Cards/List items ووحّد الـ Padding الداخلي والـ Spacing بين العناصر.
- تأكد من اتساق سلوك الـ Bottom Navigation / App Bar عبر كل الشاشات.

---

## 6) الوضوح والقراءة (Readability & Contrast)

- تحقق من نسب التباين (Contrast ratio) بين النص والخلفية في كلا الوضعين Light/Dark وفق معايير WCAG AA كحد أدنى.
- تأكد أن أحجام الخطوط قابلة للقراءة، وأن أهم الأرقام/البيانات (مثال: الرصيد، المبلغ) لها وزن بصري أكبر (حجم/Weight) من العناصر الثانوية.
- تأكد من دعم RTL كامل وصحيح بصريًا (اتجاه الأيقونات كـ Back arrow، محاذاة النصوص، اتجاه الـ Sliders/Charts إن أمكن).

---

## 7) إمكانية الوصول (Accessibility)

- أضف `Semantics` labels للعناصر التفاعلية المهمة (الأزرار، الأيقونات بدون نص).
- تأكد أن مساحة اللمس (Tap target) للعناصر التفاعلية لا تقل عن 48x48.
- تأكد أن التطبيق يبقى قابلاً للاستخدام عند تكبير حجم الخط من إعدادات النظام (`TextScaler`) دون كسر الـ Layout.

---

## 8) معاينة وتحقق (Verification)

- استخدم **Skill: `Flutter Add Widget Preview`** لمعاينة الـ Widgets الرئيسية بعد كل تعديل بشكل تفاعلي.
- استخدم **Skill: `Flutter Fix Layout Issues`** كخطوة أخيرة على كل شاشة تم تعديلها للتأكد من عدم وجود Overflow في أي حجم شاشة.
- شغّل `flutter analyze` تأكيدًا على عدم وجود تحذيرات ناتجة عن التعديلات.

---

## 9) Deliverables المطلوبة

1. تقرير تقييم أولي لكل شاشة (قبل التعديل) — المشاكل المكتشفة بالتحديد.
2. وصف Design System الجديد (الألوان، الخطوط، الـ Spacing) وأين تم تعريفه في الكود.
3. قائمة بكل شاشة تم تحسينها + وصف موجز "قبل/بعد" لأهم تغيير بصري فيها.
4. تأكيد أن كل الشاشات تدعم Light/Dark وRTL بدون كسر بصري.
5. نتيجة `flutter analyze` نظيفة بعد التعديلات.

---

## ملاحظة تنفيذية

نفّذ بالترتيب: **Design System → شاشة بشاشة (من الأكثر استخدامًا للأقل) → Consistency pass نهائي على كل التطبيق**. اعمل commit منفصل لكل شاشة/مرحلة لتسهيل المراجعة.
