/// Native monitoring/blocking is intentionally unsupported until separate
/// Android and iOS feasibility, entitlement and store-policy reviews pass.
enum PlatformCapability {
  usageRead,
  selectedAppBlocking,
  launchInterruption,
  scheduledMonitoring,
}

enum CapabilityStatus {
  available,
  authorized,
  denied,
  restricted,
  unsupported,
  error,
}

class CapabilitySnapshot {
  CapabilitySnapshot(Map<PlatformCapability, CapabilityStatus> statuses)
    : statuses = Map.unmodifiable(statuses);

  final Map<PlatformCapability, CapabilityStatus> statuses;

  CapabilityStatus statusFor(PlatformCapability capability) =>
      statuses[capability] ?? CapabilityStatus.unsupported;
}

abstract interface class PlatformInterventionService {
  Future<CapabilitySnapshot> getCapabilities();
}

/// Safe fallback for every platform until an approved native adapter exists.
class ManualOnlyInterventionService implements PlatformInterventionService {
  const ManualOnlyInterventionService();

  @override
  Future<CapabilitySnapshot> getCapabilities() async => CapabilitySnapshot({
    for (final capability in PlatformCapability.values)
      capability: CapabilityStatus.unsupported,
  });
}
