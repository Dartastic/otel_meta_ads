// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_meta_ads_suppression.dart';

const _tracerName = 'dartastic_otel_libs_meta_ads';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class MetaAdsResult {
  const MetaAdsResult({
    this.businessId,
    this.adAccountId,
    this.campaignId,
    this.adSetId,
    this.adId,
    this.objective,
    this.optimizationGoal,
    this.bidStrategy,
    this.effectiveStatus,
    this.spendMinor,
    this.currencyCode,
    this.impressions,
    this.reach,
    this.frequency,
    this.clicks,
    this.actions,
    this.roas,
    this.cpm,
    this.rateLimitUsage,
    this.statusCode,
  });

  final String? businessId;
  final String? adAccountId;
  final String? campaignId;
  final String? adSetId;
  final String? adId;

  /// `OUTCOME_AWARENESS` / `OUTCOME_TRAFFIC` / `OUTCOME_ENGAGEMENT` /
  /// `OUTCOME_LEADS` / `OUTCOME_APP_PROMOTION` / `OUTCOME_SALES`.
  final String? objective;

  /// `REACH` / `LINK_CLICKS` / `IMPRESSIONS` / `CONVERSIONS` /
  /// `LANDING_PAGE_VIEWS` / `OFFSITE_CONVERSIONS` / etc.
  final String? optimizationGoal;

  /// `LOWEST_COST_WITHOUT_CAP` / `LOWEST_COST_WITH_BID_CAP` /
  /// `COST_CAP` / `LOWEST_COST_WITH_MIN_ROAS`.
  final String? bidStrategy;

  /// `ACTIVE` / `PAUSED` / `DELETED` / `PENDING_REVIEW` /
  /// `DISAPPROVED` / `PREAPPROVED` / `PENDING_BILLING_INFO` /
  /// `CAMPAIGN_PAUSED` / `ARCHIVED` / `ADSET_PAUSED`.
  final String? effectiveStatus;

  /// Spend in minor currency units (cents for USD).
  final int? spendMinor;

  final String? currencyCode;
  final int? impressions;
  final int? reach;
  final double? frequency;
  final int? clicks;

  /// Conversion actions count (purchases, leads, etc.).
  final int? actions;

  /// Return on ad spend.
  final double? roas;

  /// Cost per mille (1000 impressions) in minor units.
  final int? cpm;

  /// Graph API call usage 0–100 (X-Business-Use-Case-Usage header).
  final int? rateLimitUsage;

  final int? statusCode;
}

class MetaAdsCallResult<T> {
  const MetaAdsCallResult({required this.value, this.result});
  final T value;
  final MetaAdsResult? result;
}

/// Wraps a Meta Ads (Marketing API) call in a CLIENT span.
/// [operation] is one of `insights.get`, `campaigns.list`,
/// `campaign.create`, `adset.create`, `ad.create`, `audiences.create`,
/// `events.send`, `creative.get`.
Future<T> tracedMetaAds<T>({
  required String operation,
  required Future<MetaAdsCallResult<T>> Function() invoke,
}) async {
  if (metaAdsInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'meta_ads',
    'rpc.method': operation,
    'meta_ads.operation': operation,
  };

  final span = _tracer().startSpan(
    'meta_ads $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.businessId != null) {
        extras.add(OTel.attributeString(
          'meta_ads.business.id',
          r.result!.businessId!,
        ));
      }
      if (r.result!.adAccountId != null) {
        extras.add(OTel.attributeString(
          'meta_ads.ad_account.id',
          r.result!.adAccountId!,
        ));
      }
      if (r.result!.campaignId != null) {
        extras.add(OTel.attributeString(
          'meta_ads.campaign.id',
          r.result!.campaignId!,
        ));
      }
      if (r.result!.adSetId != null) {
        extras.add(OTel.attributeString(
          'meta_ads.ad_set.id',
          r.result!.adSetId!,
        ));
      }
      if (r.result!.adId != null) {
        extras.add(OTel.attributeString('meta_ads.ad.id', r.result!.adId!));
      }
      if (r.result!.objective != null) {
        extras.add(OTel.attributeString(
          'meta_ads.objective',
          r.result!.objective!,
        ));
      }
      if (r.result!.optimizationGoal != null) {
        extras.add(OTel.attributeString(
          'meta_ads.optimization.goal',
          r.result!.optimizationGoal!,
        ));
      }
      if (r.result!.bidStrategy != null) {
        extras.add(OTel.attributeString(
          'meta_ads.bid.strategy',
          r.result!.bidStrategy!,
        ));
      }
      if (r.result!.effectiveStatus != null) {
        extras.add(OTel.attributeString(
          'meta_ads.effective.status',
          r.result!.effectiveStatus!,
        ));
        if (r.result!.effectiveStatus == 'DISAPPROVED') {
          span.setStatus(
            SpanStatusCode.Error,
            'Meta Ads creative DISAPPROVED',
          );
        }
      }
      if (r.result!.spendMinor != null) {
        extras.add(OTel.attributeInt(
          'meta_ads.spend.minor',
          r.result!.spendMinor!,
        ));
      }
      if (r.result!.currencyCode != null) {
        extras.add(OTel.attributeString(
          'meta_ads.currency.code',
          r.result!.currencyCode!,
        ));
      }
      if (r.result!.impressions != null) {
        extras.add(OTel.attributeInt(
          'meta_ads.impressions',
          r.result!.impressions!,
        ));
      }
      if (r.result!.reach != null) {
        extras.add(OTel.attributeInt('meta_ads.reach', r.result!.reach!));
      }
      if (r.result!.frequency != null) {
        extras.add(OTel.attributeDouble(
          'meta_ads.frequency',
          r.result!.frequency!,
        ));
      }
      if (r.result!.clicks != null) {
        extras.add(OTel.attributeInt('meta_ads.clicks', r.result!.clicks!));
      }
      if (r.result!.actions != null) {
        extras.add(OTel.attributeInt('meta_ads.actions', r.result!.actions!));
      }
      if (r.result!.roas != null) {
        extras.add(OTel.attributeDouble('meta_ads.roas', r.result!.roas!));
      }
      if (r.result!.cpm != null) {
        extras.add(OTel.attributeInt('meta_ads.cpm.minor', r.result!.cpm!));
      }
      if (r.result!.rateLimitUsage != null) {
        extras.add(OTel.attributeInt(
          'meta_ads.rate_limit.usage',
          r.result!.rateLimitUsage!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Meta Ads HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
