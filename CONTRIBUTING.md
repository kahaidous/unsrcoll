# Contributing

## Development workflow

1. Branch from `main` using `feat/`, `fix/`, `docs/` or `chore/` plus a short topic.
2. Keep changes focused; avoid adding tracking, network services or new permissions without a reviewed product/privacy decision.
3. Run `dart format lib test`, `flutter analyze` and `flutter test` before opening a pull request.
4. Open a PR against `main`, describe user-visible changes and limitations, and link relevant issues or decisions.
5. Wait for CI and review before merging; do not push product implementation directly to `main`.

## Product safety checklist

- Keep language neutral and non-clinical; do not promise to cure “brain rot,” restore cognition or treat a health condition.
- Keep manual focus and reflection useful when OS permissions are absent or revoked.
- Do not show usage data or an active block unless a native adapter has confirmed the capability and its current status.
- Explain permissions at the moment they are needed and provide the supported manual fallback.
- Keep reflection text, app names and usage records out of logs and telemetry.
- For OS-level features, obtain separate Apple entitlement/API and Google Play policy review before shipping or describing them as available.
