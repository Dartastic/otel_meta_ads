// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_meta_ads/otel_meta_ads.dart';

/// Traces Meta Ads (Marketing calls with OpenTelemetry.
///
/// `otel_meta_ads` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Meta Ads (Marketing call in
/// [tracedMetaAds]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'meta-ads-example');

  // Wraps a Meta Ads (Marketing API) call in a CLIENT span.
  final metaAdsId = await tracedMetaAds<String>(
    operation: 'campaign.create',
    invoke: () async {
      // Make the Meta Ads (Marketing call here, then report what it returned.
      const id = 'meta_ads_8f3a2c';
      return const MetaAdsCallResult(
          value: id,
          result: MetaAdsResult(
              businessId: 'business_8f3a2c',
              adAccountId: 'adaccount_8f3a2c',
              campaignId: 'campaign_8f3a2c',
              adSetId: 'adset_8f3a2c',
              adId: 'ad_8f3a2c',
              objective: 'OUTCOME_AWARENESS',
              optimizationGoal: 'REACH',
              bidStrategy: 'LOWEST_COST_WITHOUT_CAP',
              effectiveStatus: 'ACTIVE',
              spendMinor: 1,
              currencyCode: 'usd',
              impressions: 1,
              reach: 1,
              frequency: 0.5,
              clicks: 1,
              actions: 1,
              roas: 0.5,
              cpm: 1,
              rateLimitUsage: 25,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedMetaAds campaign.create returned $metaAdsId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutMetaAdsInstrumentationAsync.
  await runWithoutMetaAdsInstrumentationAsync(
    () => tracedMetaAds<String>(
      operation: 'campaign.create',
      invoke: () async {
        const id = 'meta_ads_8f3a2c';
        return const MetaAdsCallResult(
            value: id,
            result: MetaAdsResult(
                businessId: 'business_8f3a2c',
                adAccountId: 'adaccount_8f3a2c',
                campaignId: 'campaign_8f3a2c',
                adSetId: 'adset_8f3a2c',
                adId: 'ad_8f3a2c',
                objective: 'OUTCOME_AWARENESS',
                optimizationGoal: 'REACH',
                bidStrategy: 'LOWEST_COST_WITHOUT_CAP',
                effectiveStatus: 'ACTIVE',
                spendMinor: 1,
                currencyCode: 'usd',
                impressions: 1,
                reach: 1,
                frequency: 0.5,
                clicks: 1,
                actions: 1,
                roas: 0.5,
                cpm: 1,
                rateLimitUsage: 25,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
