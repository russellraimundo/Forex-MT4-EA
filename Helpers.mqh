//+------------------------------------------------------------------+
//|                                                      Helpers.mqh |
//|                                                 Russell Raimundo |
//|                                                https://ruraim.io |
//+------------------------------------------------------------------+
#property copyright "Russell Raimundo"
#property link      "https://ruraim.io"

double getPipValue() {
    if (_Digits >= 4) return 0.0001;
    return 0.01;
}

double optimalLotSize(double maxRiskPrc, int maxLossInPips) {
    double accEquity = AccountEquity();
    double lotSize = MarketInfo(NULL, MODE_LOTSIZE);
    double tickValue = MarketInfo(NULL, MODE_TICKVALUE);    
    
    if (Digits <= 3) tickValue /= 3;
    
    double maxLossDollar = accEquity * maxRiskPrc;
    double maxLossInQuotedCurr = maxLossDollar / tickValue;
    double optimalLotSize = NormalizeDouble(maxLossInQuotedCurr / (maxLossInPips * getPipValue()) / lotSize, 2);
    return optimalLotSize;
}

double optimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss) {
    int maxLossInPips = MathAbs(entryPrice - stopLoss) / getPipValue();
    return optimalLotSize(maxRiskPrc, maxLossInPips);
}