# Consumer ProGuard rules for library
# 这些规则会被包含在 AAR 中，客户使用时自动应用

# Keep all public classes and methods
-keep public class cn.shengwang.beauty.** { *; }

# Keep data classes
-keep class cn.shengwang.beauty.ui.** { *; }
-keep class cn.shengwang.beauty.core.** { *; }

# Keep ViewBinding classes
-keep class cn.shengwang.beauty.databinding.** { *; }

# Keep R class
-keep class cn.shengwang.beauty.R$* { *; }
