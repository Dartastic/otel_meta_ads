// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_meta_ads/otel_meta_ads.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_meta_ads-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('insights.get records spend + reach + ROAS + rate limit', () async {
    await tracedMetaAds<String>(
      operation: 'insights.get',
      invoke: () async => const MetaAdsCallResult(
        value: 'ok',
        result: MetaAdsResult(
          businessId: 'biz_1',
          adAccountId: 'act_1',
          campaignId: 'cam_1',
          objective: 'OUTCOME_SALES',
          optimizationGoal: 'OFFSITE_CONVERSIONS',
          bidStrategy: 'LOWEST_COST_WITH_MIN_ROAS',
          effectiveStatus: 'ACTIVE',
          spendMinor: 250000,
          currencyCode: 'USD',
          impressions: 100000,
          reach: 45000,
          frequency: 2.2,
          clicks: 1800,
          actions: 75,
          roas: 3.4,
          cpm: 2500,
          rateLimitUsage: 38,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('meta_ads insights.get')!);
    expect(a['meta_ads.business.id'], 'biz_1');
    expect(a['meta_ads.objective'], 'OUTCOME_SALES');
    expect(a['meta_ads.bid.strategy'], 'LOWEST_COST_WITH_MIN_ROAS');
    expect(a['meta_ads.spend.minor'], 250000);
    expect(a['meta_ads.reach'], 45000);
    expect(a['meta_ads.roas'], 3.4);
    expect(a['meta_ads.rate_limit.usage'], 38);
  });

  test('DISAPPROVED creative sets span error', () async {
    await tracedMetaAds<String>(
      operation: 'ad.create',
      invoke: () async => const MetaAdsCallResult(
        value: 'ok',
        result: MetaAdsResult(
          adId: 'ad_1',
          effectiveStatus: 'DISAPPROVED',
        ),
      ),
    );
    expect(
      spans.findSpanByName('meta_ads ad.create')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutMetaAdsInstrumentationAsync(() async {
      await tracedMetaAds<String>(
        operation: 'campaigns.list',
        invoke: () async => const MetaAdsCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('meta_ads '), isEmpty);
  });
}
