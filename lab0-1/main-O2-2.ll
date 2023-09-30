; ModuleID = 'main.c'
source_filename = "main.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@.str.1 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

; Function Attrs: nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #0 {
  %1 = alloca i32, align 4
  %2 = bitcast i32* %1 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %2) #3
  %3 = call i32 (i8*, ...) @__isoc99_scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i64 0, i64 0), i32* nonnull %1)
  %4 = load i32, i32* %1, align 4, !tbaa !2
  %5 = icmp slt i32 %4, 2
  br i1 %5, label %79, label %6

6:                                                ; preds = %0
  %7 = add i32 %4, -1
  %8 = icmp ult i32 %7, 8
  br i1 %8, label %70, label %9

9:                                                ; preds = %6
  %10 = and i32 %7, -8
  %11 = or i32 %10, 2
  %12 = add i32 %10, -8
  %13 = lshr exact i32 %12, 3
  %14 = add nuw nsw i32 %13, 1
  %15 = and i32 %14, 3
  %16 = icmp ult i32 %12, 24
  br i1 %16, label %42, label %17

17:                                               ; preds = %9
  %18 = sub nsw i32 %14, %15
  br label %19

19:                                               ; preds = %19, %17
  %20 = phi <4 x i32> [ <i32 1, i32 1, i32 1, i32 1>, %17 ], [ %37, %19 ]
  %21 = phi <4 x i32> [ <i32 1, i32 1, i32 1, i32 1>, %17 ], [ %38, %19 ]
  %22 = phi <4 x i32> [ <i32 2, i32 3, i32 4, i32 5>, %17 ], [ %39, %19 ]
  %23 = phi i32 [ %18, %17 ], [ %40, %19 ]
  %24 = add <4 x i32> %22, <i32 4, i32 4, i32 4, i32 4>
  %25 = mul <4 x i32> %20, %22
  %26 = mul <4 x i32> %21, %24
  %27 = add <4 x i32> %22, <i32 8, i32 8, i32 8, i32 8>
  %28 = add <4 x i32> %22, <i32 12, i32 12, i32 12, i32 12>
  %29 = mul <4 x i32> %25, %27
  %30 = mul <4 x i32> %26, %28
  %31 = add <4 x i32> %22, <i32 16, i32 16, i32 16, i32 16>
  %32 = add <4 x i32> %22, <i32 20, i32 20, i32 20, i32 20>
  %33 = mul <4 x i32> %29, %31
  %34 = mul <4 x i32> %30, %32
  %35 = add <4 x i32> %22, <i32 24, i32 24, i32 24, i32 24>
  %36 = add <4 x i32> %22, <i32 28, i32 28, i32 28, i32 28>
  %37 = mul <4 x i32> %33, %35
  %38 = mul <4 x i32> %34, %36
  %39 = add <4 x i32> %22, <i32 32, i32 32, i32 32, i32 32>
  %40 = add i32 %23, -4
  %41 = icmp eq i32 %40, 0
  br i1 %41, label %42, label %19, !llvm.loop !6

42:                                               ; preds = %19, %9
  %43 = phi <4 x i32> [ undef, %9 ], [ %37, %19 ]
  %44 = phi <4 x i32> [ undef, %9 ], [ %38, %19 ]
  %45 = phi <4 x i32> [ <i32 1, i32 1, i32 1, i32 1>, %9 ], [ %37, %19 ]
  %46 = phi <4 x i32> [ <i32 1, i32 1, i32 1, i32 1>, %9 ], [ %38, %19 ]
  %47 = phi <4 x i32> [ <i32 2, i32 3, i32 4, i32 5>, %9 ], [ %39, %19 ]
  %48 = icmp eq i32 %15, 0
  br i1 %48, label %60, label %49

49:                                               ; preds = %42, %49
  %50 = phi <4 x i32> [ %55, %49 ], [ %45, %42 ]
  %51 = phi <4 x i32> [ %56, %49 ], [ %46, %42 ]
  %52 = phi <4 x i32> [ %57, %49 ], [ %47, %42 ]
  %53 = phi i32 [ %58, %49 ], [ %15, %42 ]
  %54 = add <4 x i32> %52, <i32 4, i32 4, i32 4, i32 4>
  %55 = mul <4 x i32> %50, %52
  %56 = mul <4 x i32> %51, %54
  %57 = add <4 x i32> %52, <i32 8, i32 8, i32 8, i32 8>
  %58 = add i32 %53, -1
  %59 = icmp eq i32 %58, 0
  br i1 %59, label %60, label %49, !llvm.loop !8

60:                                               ; preds = %49, %42
  %61 = phi <4 x i32> [ %43, %42 ], [ %55, %49 ]
  %62 = phi <4 x i32> [ %44, %42 ], [ %56, %49 ]
  %63 = mul <4 x i32> %62, %61
  %64 = shufflevector <4 x i32> %63, <4 x i32> undef, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
  %65 = mul <4 x i32> %63, %64
  %66 = shufflevector <4 x i32> %65, <4 x i32> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %67 = mul <4 x i32> %65, %66
  %68 = extractelement <4 x i32> %67, i32 0
  %69 = icmp eq i32 %7, %10
  br i1 %69, label %79, label %70

70:                                               ; preds = %60, %6
  %71 = phi i32 [ 1, %6 ], [ %68, %60 ]
  %72 = phi i32 [ 2, %6 ], [ %11, %60 ]
  br label %73

73:                                               ; preds = %70, %73
  %74 = phi i32 [ %76, %73 ], [ %71, %70 ]
  %75 = phi i32 [ %77, %73 ], [ %72, %70 ]
  %76 = mul nsw i32 %74, %75
  %77 = add nuw nsw i32 %75, 1
  %78 = icmp slt i32 %75, %4
  br i1 %78, label %73, label %79, !llvm.loop !10

79:                                               ; preds = %73, %60, %0
  %80 = phi i32 [ 1, %0 ], [ %68, %60 ], [ %76, %73 ]
  %81 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str.1, i64 0, i64 0), i32 %80)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %2) #3
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nofree nounwind
declare dso_local i32 @__isoc99_scanf(i8* nocapture readonly, ...) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare dso_local i32 @printf(i8* nocapture readonly, ...) local_unnamed_addr #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0-4ubuntu1 "}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.isvectorized", i32 1}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.unroll.disable"}
!10 = distinct !{!10, !11, !7}
!11 = !{!"llvm.loop.unroll.runtime.disable"}
