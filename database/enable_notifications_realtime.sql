-- ============================================================
-- تفعيل Realtime لجدول الإشعارات في Supabase
-- قم بتشغيل هذا الأمر في SQL Editor داخل لوحة تحكم Supabase
-- ============================================================

-- إضافة جدول الإشعارات لمنشور Supabase Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
