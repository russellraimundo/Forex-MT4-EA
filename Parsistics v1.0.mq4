//+------------------------------------------------------------------+
//|                                              Parsistics v1.0.mq4 |
//|                                                 Russell Raimundo |
//|                                                https://ruraim.io |
//+------------------------------------------------------------------+
#property copyright "Russell Raimundo"
#property link      "https://ruraim.io"
#property version   "1.00"
#include <Helpers.mqh>

input double LotAmount = 0.05;
input double riskPercentage = 0.02;

string parabolic;
string stochastic;
string rsi;    
string signal;

int OnInit() {

  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    
}

void OnTick() {
  
    parabolic = parabolicSARSignal();
    stochastic = stochasticSignal();
    rsi = RSISignal();    
    signal = "";    
    
    if (parabolic == "BUY" && rsi == "BUY" && OrdersTotal() == 0) {
        signal = "Buy";
        OrderSend(_Symbol, OP_BUY, LotAmount, Ask, 3, 0, 0);
    } else if (parabolic == "SELL" && rsi == "SELL" && OrdersTotal() == 0) {
        signal = "Sell";
        OrderSend(_Symbol, OP_SELL, LotAmount, Bid, 3, 0, 0);
    }
        
    updateTrailingStop();
    
    signalMonitor();
  
}

void signalMonitor() {
    Comment("Parabolic SAR Signal: ", parabolic, "\n"
            "Stochastic Signal   : ", stochastic, "\n"
            "RSI Signal          : ", rsi, "\n",
            "Major Action        : ", signal);
}

string parabolicSARSignal() {
    string signal = "";
    double sarValue = iSAR(_Symbol,_Period , 0.02, 0.2, 0);
    if (sarValue < Close[0]) signal = "BUY";
    if (sarValue > Close[0]) signal = "SELL";
    return signal;
}

string stochasticSignal() {
    string signal = "";
    double Kline0 = iStochastic(_Symbol, _Period, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
    double Dline0 = iStochastic(_Symbol, _Period, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 0);
    
    double Kline1 = iStochastic(_Symbol, _Period, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
    double Dline1 = iStochastic(_Symbol, _Period, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);
    
    if (Kline0 < 20 && Dline0 < 20) {
        if (Dline0 < Kline0 && Dline1 > Kline1) {
            signal = "BUY";
        }
    }
    
    if (Kline0 > 80 && Dline0 > 80) {
        if (Dline0 > Kline0 && Dline1 < Kline1) {
            signal = "SELL";
        }
    }
    
    return signal;
         
}

string RSISignal() {
    string signal = "";
    double rsi = iRSI(_Symbol, _Period, 14, PRICE_CLOSE, 0);
    if (rsi < 30) signal = "BUY";
    if (rsi > 70) signal = "SELL";
    return signal;
}

void updateTrailingStop() {
    for (int o = 0; o < OrdersTotal(); o++) {
        
        if (OrderSelect(o, SELECT_BY_POS, MODE_TRADES) && OrderSymbol()==_Symbol) {
            double sar = iSAR(_Symbol,_Period , 0.02, 0.2, 0);
            double atr = iATR(_Symbol, _Period, 14, 0);
            
            bool modify = false;
            double lotSize;
            
            if (OrderType() == OP_BUY) {
                if (OrderStopLoss() < sar || OrderStopLoss() == 0) {            
                    modify = OrderModify(OrderTicket(), OrderOpenPrice(), sar - 31 * _Point, 0, 0);                   
                }
            } else if (OrderType() == OP_SELL) {
                if (OrderStopLoss() > sar || OrderStopLoss() == 0) {      
                    modify = OrderModify(OrderTicket(), OrderOpenPrice(), sar + 31 * _Point, 0, 0);
                }                    
            }
            
        }
    
    }    
}
