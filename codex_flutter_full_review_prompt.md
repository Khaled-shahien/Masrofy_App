# 🎯 Codex Master Prompt — Full Project Review & Enhancement

> انسخ هذا البرومبت كاملاً وضعه في Codex كـ Task واحدة، أو قسّمه على عدة Sessions حسب حجم المشروع.

---

## 0) قبل أي شيء — Context Loading (إلزامي)

قبل البدء في أي تعديل، يجب عليك تنفيذ الخطوات التالية **بالترتيب**:

1. اقرأ ملف `rules.md` في جذر المشروع بالكامل، وطبّق كل القواعد الواردة فيه (Code style, Architecture constraints, Naming conventions, Commit rules, أي Do/Don't محدد) على كل خطوة لاحقة في هذه المهمة دون استثناء.
2. اعمل `tree` كامل لهيكل المشروع (lib/, test/, assets/, pubspec.yaml) وابنِ خريطة ذهنية لـ:
   - الـ Layers الحالية (Presentation / Domain / Data)
   - الـ State Management المستخدم (BLoC/Cubit)
   - الـ DI (GetIt) وكيف يتم تسجيل الـ Dependencies
   - الـ Models (Freezed) والـ Repositories
   - الـ Routing (go_router)
   - أي Firestore collections أو مصادر بيانات
3. اقرأ `pubspec.yaml` وحدد الـ dependencies الحالية وإصداراتها، وحدد ما هو Deprecated أو قابل للترقية.
4. لا تبدأ أي تعديل فعلي قبل إخراج تقرير تحليل أولي (انظر القسم 8 - Deliverables) يوضح فهمك للمشروع.

---

## 1) Architecture & SOLID Audit

- تحقق من الالتزام الكامل بـ **Clean Architecture** (data / domain / presentation) في كل Feature، وأعد تنظيم أي ملف موجود في مكان خاطئ.
- طبّق مبادئ **SOLID** بشكل صريح:
  - **S**: افصل أي Class/Cubit يقوم بأكثر من مسؤولية واحدة.
  - **O**: استخدم Abstract classes / Interfaces بدل التعديل المباشر عند إضافة سلوك جديد.
  - **L**: تأكد أن أي Subclass أو Implementation لا يكسر العقد الأصلي.
  - **I**: قسّم أي Interface كبير إلى Interfaces أصغر مخصصة.
  - **D**: تأكد أن الـ Presentation layer يعتمد على Abstractions (Repository interfaces) وليس على Implementations مباشرة، عبر GetIt.
- استخدم **Skill: `Flutter Apply Architecture Best Practices`** لتطبيق هذا القسم بشكل كامل ومنهجي.
- استخدم **Skill: `Dart Migrate to Checks Package`** إذا وُجد استخدام لـ `expect`/legacy assertions يحتاج تحديث.
- استخدم **Skill: `Dart Resolve Package Conflicts`** لحل أي تعارض إصدارات في `pubspec.lock`.

---

## 2) Features — تطوير ورفع المستوى

- راجع كل Feature حالية وحدد:
  - Features ناقصة منطقيًا (Empty states, Error states, Loading states, Retry logic).
  - أي Business logic موجود بالخطأ داخل الـ UI بدل الـ Cubit/UseCase.
- أضف أي Feature تحسينية منطقية للمشروع (Pagination, Caching, Offline-first behavior, Search/Filter) بما يتناسب مع طبيعة التطبيق.
- استخدم **Skill: `Flutter Use Http Package`** إذا كانت هناك حاجة لطلبات شبكة، وتأكد من معالجة الأخطاء (timeout, no internet, server error) بشكل موحّد.
- استخدم **Skill: `Flutter Implement Json Serialization`** لأي Model جديد أو معاد هيكلته، بالتوافق مع نمط Freezed الحالي في المشروع.

---

## 3) UI/UX — تحسين شامل

- أعد بناء أي شاشة تستخدم `ListView`/`Column` داخل `SingleChildScrollView` بشكل غير كفء إلى **Slivers** (`CustomScrollView`, `SliverList`, `SliverAppBar`, `SliverToBoxAdapter`) لتحسين الأداء والـ scrolling experience، خصوصًا في الشاشات الطويلة/الـ Dashboards.
- طبّق **Material 3** بشكل متسق (`useMaterial3: true`، `ColorScheme.fromSeed`).
- حسّن الـ Spacing/Typography/Elevation لتكون متسقة عبر كل الشاشات (استخدم Theme extensions بدل القيم الثابتة المتكررة).
- استخدم **Skill: `Flutter Fix Layout Issues`** لاكتشاف وإصلاح أي Overflow أو مشاكل layout موجودة فعليًا في الكود.
- استخدم **Skill: `Flutter Build Responsive Layout`** (`LayoutBuilder`, `MediaQuery`) لجعل التطبيق يعمل بشكل سليم على أحجام شاشات مختلفة (Mobile/Tablet).
- استخدم **Skill: `Flutter Add Widget Preview`** لإضافة معاينات تفاعلية للـ widgets الرئيسية أثناء التطوير.

---

## 4) Localization (تعدد اللغات)

- أضف دعم **Localization** كامل باستخدام `flutter_localizations` + `intl`:
  - أنشئ ملفات `.arb` للعربية والإنجليزية على الأقل (`app_ar.arb`, `app_en.arb`).
  - استبدل كل Hardcoded string في الكود بمفاتيح Localization.
  - تأكد من دعم **RTL** بشكل كامل للعربية (اتجاه النص، المحاذاة، الأيقونات).
- استخدم **Skill: `Flutter Setup Localization`** لتنفيذ هذا القسم بالكامل بالطريقة القياسية الموصى بها.

---

## 5) Dark Mode / Light Mode

- أنشئ `ThemeData` منفصل لكل من الوضعين (Light/Dark) باستخدام `ColorScheme` متسق.
- اربط التبديل بـ `ThemeMode` قابل للتخزين (مثلاً عبر Cubit + Shared Preferences) بحيث يتذكر اختيار المستخدم.
- تأكد أن كل الألوان في المشروع تُستمد من الـ Theme وليست Hardcoded، حتى تعمل بسلاسة في الوضعين.

---

## 6) Routing

- راجع إعداد **go_router** الحالي وتأكد من:
  - استخدام **Declarative Routing** بشكل صحيح (Nested routes, Shell routes للـ Bottom Navigation إن وجد).
  - حماية المسارات (Guards) حسب حالة الـ Auth/الصلاحيات إن وُجدت.
- استخدم **Skill: `Flutter Setup Declarative Routing`** لتطبيق أفضل الممارسات هنا.

---

## 7) Testing & Quality Assurance

نفّذ تغطية اختبارات شاملة باستخدام الـ Skills التالية بالترتيب:

1. **Skill: `Dart Add Unit Test`** — لكتابة وتنظيم Unit tests لكل UseCase/Repository/Cubit منطقي.
2. **Skill: `Dart Generate Test Mocks`** — لإنشاء Mock objects للـ Dependencies (Repositories, DataSources) بدل الاعتماد على بيانات حقيقية في الاختبارات.
3. **Skill: `Flutter Add Widget Test`** — لاختبار الـ Widgets الأساسية (Component-level).
4. **Skill: `Flutter Add Integration Test`** — لإعداد Flutter Driver واختبار تدفقات المستخدم الكاملة (End-to-end).
5. **Skill: `Dart Collect Coverage`** — لقياس نسبة تغطية الكود بالاختبارات وتحديد المناطق غير المغطاة.
6. **Skill: `Dart Run Static Analysis`** — لتشغيل `dart analyze` وإصلاح كل التحذيرات (warnings) والأخطاء الظاهرة.
7. **Skill: `Dart Use Pattern Matching`** — لتحديث أي `if/else` أو `switch` تقليدي إلى Pattern matching/switch expressions حديثة حيث يُحسّن القراءة.
8. **Skill: `Dart Fix Runtime Errors`** — عند مواجهة أي خطأ Runtime أثناء التطوير أو التشغيل، استخدم `get_runtime_errors` + LSP لتشخيصه وإصلاحه بدل التخمين.

تأكد من تشغيل `flutter test` في النهاية والتأكد من نجاح **All tests passed** قبل اعتبار المهمة منتهية.

---

## 8) تنظيم الملفات (Project Structure)

أعد هيكلة `lib/` لتصبح بالشكل التالي (عدّل حسب الموجود فعليًا دون كسر ما هو موجود بلا داعٍ):

```
lib/
  core/                # utils, constants, theme, errors, di (GetIt), extensions
  l10n/                # ملفات ARB والـ localization generated
  features/
    <feature_name>/
      data/
        datasources/
        models/        # Freezed models
        repositories/
      domain/
        entities/
        repositories/  # abstract
        usecases/
      presentation/
        cubit/          # أو bloc
        pages/
        widgets/
  app.dart
  main.dart
```

---

## 9) Deliverables المطلوبة منك (Codex) في نهاية المهمة

1. **تقرير تحليل أولي** (قبل التعديل): فهمك للمشروع، المشاكل المكتشفة، وخطة العمل المرتبة بالأولوية.
2. **قائمة التغييرات** لكل Feature/ملف تم تعديله، مع سبب كل تعديل.
3. **نتيجة `flutter analyze`** نظيفة (بدون warnings حرجة).
4. **نتيجة `flutter test`** — All tests passed، مع نسبة الـ Coverage.
5. **Before/After** موجز لأهم تحسينات الـ UI/UX (وصف نصي كافٍ إن لم تتوفر لقطات شاشة).
6. الالتزام الكامل بكل ما ورد في `rules.md` طوال التنفيذ — أي تعارض بين هذا البرومبت وملف `rules.md`، الأولوية دائمًا لـ `rules.md`.

---

## ملاحظة تنفيذية

نفّذ المهمة على مراحل (Architecture → Features → UI/UX → Localization → Theming → Testing) بدل تنفيذ كل شيء دفعة واحدة، واعمل commit منطقي بعد كل مرحلة بحيث يسهل المراجعة والـ rollback عند الحاجة.
