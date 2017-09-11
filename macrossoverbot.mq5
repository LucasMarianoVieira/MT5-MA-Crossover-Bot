#property copyright "TheSaberLion"
#property link      "https://www.mql5.com"
#property version   "1.00"

input int MAPeriodShort=9;
input int MAPeriodLong=21;
input int MAShift=0;
input ENUM_MA_METHOD MAMethodS= MODE_SMA;
input ENUM_MA_METHOD MAMethodL= MODE_SMA;
input ENUM_APPLIED_PRICE MAPrice= PRICE_CLOSE;
input double stopLoss=0.1;
input double takeProfit=0.3;
input int volume=100;

enum orderType{
   orderBuy,
   orderSell
};

datetime candleTimes[],lastCandleTime;

MqlTradeRequest request;
MqlTradeResult result;
MqlTradeCheckResult checkResult;

bool checkNewCandle(datetime &candles[],datetime &last){
	bool newCandle=false;

	CopyTime(_Symbol,_Period,0,3,candles);

	if(last!=0){
		if(candles[0]>last){
			newCandle=true;
			last=candles[0];
		}
	}else{
		last=candles[0];
	}

	return newCandle;
}

bool closePosition(){
	double vol=0;
	long type=WRONG_VALUE;
	long posID=0;

	ZeroMemory(request);

	if(PositionSelect(_Symbol)){
		vol=PositionGetDouble(POSITION_VOLUME);
		type=PositionGetInteger(POSITION_TYPE);
		posID=PositionGetInteger(POSITION_IDENTIFIER);

		request.sl=PositionGetDouble(POSITION_SL);
		request.tp=PositionGetDouble(POSITION_TP);     
	}else{
		return false;
	}

	request.symbol=_Symbol;
	request.volume=vol;
	request.action=TRADE_ACTION_DEAL;
	request.type_filling=ORDER_FILLING_FOK;
	request.deviation=10;
	double price=0;


	if(type==POSITION_TYPE_BUY){
		//Buy
		request.type=ORDER_TYPE_BUY;
		price=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
	}else if(POSITION_TYPE_SELL){
		//Sell
		request.type=ORDER_TYPE_SELL;
		price=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
	}

	request.price=price;

	if(OrderCheck(request,checkResult)){
		Print("Checked!");
	}else{
		Print("Not correct! ERROR :"+IntegerToString(checkResult.retcode));
		return false;
	}

	if(OrderSend(request,result)){
		Print("Successful send!");
	}else{
		Print("Error order not send!");
		return false;
	}

	if(result.retcode==TRADE_RETCODE_DONE || result.retcode==TRADE_RETCODE_PLACED){
		Print("Trade Placed!");
		return true;
	}else{
		return false;
	}   
   
}

bool makePosition(orderType type){
	ZeroMemory(request);
	request.symbol=_Symbol;
	request.volume=volume;
	request.action=TRADE_ACTION_DEAL;
	request.type_filling=ORDER_FILLING_FOK;
	double price=0;

	if(type==orderBuy){
		//Buy
		request.type=ORDER_TYPE_BUY;
		price=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
		request.sl=NormalizeDouble(price-stopLoss,_Digits);
		request.tp=NormalizeDouble(price+takeProfit,_Digits);
		
	}else if(type==orderSell){
		//Sell
		request.type=ORDER_TYPE_SELL;
		price=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
		request.sl=NormalizeDouble(price+stopLoss,_Digits);
		request.tp=NormalizeDouble(price-takeProfit,_Digits);

	}
	request.deviation=10;
	request.price=price;


	if(OrderCheck(request,checkResult)){
		Print("Checked!");
	}else{
		Print("Not Checked! ERROR :"+IntegerToString(checkResult.retcode));
		return false;
	}

	if(OrderSend(request,result)){
		Print("Ordem enviada com sucesso!");
	}else{
		Print("Ordem não enviada!");
		return false;
	}

	if(result.retcode==TRADE_RETCODE_DONE || result.retcode==TRADE_RETCODE_PLACED){
		Print("Trade Placed!");
		return true;
	}else{
		return false;
	}
}

int OnInit(){
	ArraySetAsSeries(candleTimes,true);
	return(0);
}



void OnTick(){
	
	if(checkNewCandle(candleTimes,lastCandleTime)){
		double maS[];
		double maL[];
		ArraySetAsSeries(maS,true);
		ArraySetAsSeries(maL,true);
		double candleClose[];
		ArraySetAsSeries(candleClose,true);
		int maSHandle= iMA(_Symbol,_Period,MAPeriodShort,MAShift,MAMethodS,MAPrice);
		int maLHandle= iMA(_Symbol,_Period,MAPeriodLong,MAShift,MAMethodL,MAPrice);
		CopyBuffer(maSHandle,0,0,3,maS);
		CopyBuffer(maLHandle,0,0,3,maL);
		CopyClose(_Symbol,_Period,0,3,candleClose);

		if((maS[1] < maL[1])&&(maS[0]>maL[0])){
			//cross up
			Print("Cross above!");
			closePosition();
			makePosition(orderBuy);

		}else if((maS[1]>maL[1])&&(maS[0]<maL[0])){
			//cross down
			Print("Cross under!");
			closePosition();
			makePosition(orderSell);     

		}else{
			//trailing

		}
	}
  
}


   

