import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/review_usecases.dart';
import '../providers/my_reviews_notifier.dart';
import '../providers/profile_providers.dart';
import '../widgets/rating_stars.dart';

/// Writes a new review, or edits an existing one.
///
/// Reached from the "to review" list (`GET /reviews/reviewable`) or from the
/// edit action on a review the customer already wrote. Has no route of its
/// own — it is pushed with its subject, which a path parameter could not
/// carry without a second fetch.
class WriteReviewPage extends ConsumerStatefulWidget {
  const WriteReviewPage({
    required this.productId,
    required this.productName,
    super.key,
    this.imageUrl,
    this.existingReview,
  });

  /// Editing an existing review. Null means composing a new one.
  final Review? existingReview;

  final String productId;
  final String productName;
  final String? imageUrl;

  bool get isEditing => existingReview != null;

  @override
  ConsumerState<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends ConsumerState<WriteReviewPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _commentController;

  late int _rating;
  bool _isSaving = false;
  ValidationFailure? _fieldErrors;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingReview;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _commentController = TextEditingController(text: existing?.comment ?? '');
    // The backend accepts 1..5 only, so a new review starts at the top of the
    // scale rather than at an impossible zero.
    _rating = existing?.rating ?? 5;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `POST /reviews` sits behind `requireVerifiedEmail`. Checking here turns
    // an opaque 403 into something the customer can act on.
    final isVerified = ref.watch(currentUserProvider)?.isEmailVerified ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit review' : 'Write a review'),
      ),
      body: isVerified ? _buildForm(context) : const _VerificationRequired(),
    );
  }

  Widget _buildForm(BuildContext context) => Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.pageGutter),
          children: [
            Row(
              children: [
                AppNetworkImage(
                  url: widget.imageUrl,
                  width: 56,
                  height: 72,
                  borderRadius: AppDimens.borderRadiusSm,
                ),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: Text(
                    widget.productName,
                    style: context.text.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space24),
            Text('Your rating', style: context.text.labelLarge),
            const SizedBox(height: AppDimens.space4),
            Center(
              child: RatingInput(
                rating: _rating,
                onChanged: (value) => setState(() => _rating = value),
              ),
            ),
            const SizedBox(height: AppDimens.space24),
            TextFormField(
              controller: _titleController,
              maxLength: 120,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Headline',
                helperText: 'Optional',
                errorText: _fieldErrors?.forField('title'),
              ),
            ),
            const SizedBox(height: AppDimens.space8),
            TextFormField(
              controller: _commentController,
              maxLength: 2000,
              minLines: 5,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Your review',
                alignLabelWithHint: true,
                errorText: _fieldErrors?.forField('comment'),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.length < 10) {
                  return 'Tell us a little more — at least 10 characters.';
                }
                if (trimmed.length > 2000) {
                  return 'Please keep it under 2000 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimens.space24),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: Text(
                _isSaving
                    ? 'SAVING…'
                    : (widget.isEditing ? 'SAVE CHANGES' : 'POST REVIEW'),
              ),
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Reviews are published straight away and shown with your name.',
              style: context.text.bodySmall?.copyWith(
                color: context.palette.inkSubtle,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
      _fieldErrors = null;
    });

    final failure = widget.isEditing ? await _saveEdit() : await _create();

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _fieldErrors = failure is ValidationFailure ? failure : null;
    });

    if (failure == null) {
      // Both lists change: a new review disappears from "to review" and
      // appears under "my reviews".
      ref.invalidate(myReviewsProvider);
      ref.invalidate(reviewableProductsProvider);
      context.showSnack(
        widget.isEditing ? 'Review updated.' : 'Thanks for your review.',
      );
      Navigator.of(context).maybePop(true);
      return;
    }

    context.showSnack(
      // 409 means one review per product per user has already been used up.
      // The generic conflict copy would not explain that.
      failure is ConflictFailure
          ? 'You have already reviewed this product. Edit your existing '
              'review instead.'
          : failure.message,
      isError: true,
    );
  }

  Future<Failure?> _create() async {
    final result = await ref.read(createReviewUseCaseProvider)(
      CreateReviewParams(
        productId: widget.productId,
        rating: _rating,
        comment: _commentController.text,
        title: _titleController.text,
      ),
    );
    return result.failureOrNull;
  }

  Future<Failure?> _saveEdit() async {
    final existing = widget.existingReview!;
    final title = _titleController.text.trim();
    final comment = _commentController.text.trim();

    // Only what actually changed is sent; a PATCH that changes nothing is a
    // 400, and this catches it before the round trip.
    final nextRating = _rating == existing.rating ? null : _rating;
    final nextTitle = title == existing.title ? null : title;
    final nextComment = comment == existing.comment ? null : comment;

    if (nextRating == null && nextTitle == null && nextComment == null) {
      return const ValidationFailure('Nothing to save.');
    }

    return ref.read(myReviewsProvider.notifier).editReview(
          reviewId: existing.id,
          rating: nextRating,
          title: nextTitle,
          comment: nextComment,
        );
  }
}

/// Shown instead of the form when the address is not confirmed.
class _VerificationRequired extends StatelessWidget {
  const _VerificationRequired();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                size: 44,
                color: context.palette.warning,
              ),
              const SizedBox(height: AppDimens.space20),
              Text(
                'Confirm your email first',
                style: context.text.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                'Only customers with a confirmed email address can post '
                'reviews. Open the link we sent you, then come back — you can '
                'resend it from your account page.',
                style: context.text.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.space24),
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('GO BACK'),
              ),
            ],
          ),
        ),
      );
}
