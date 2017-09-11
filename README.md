# MT5-SMA-Crossover-Bot

This is the code for a very simple Expert Advisor(bot) for
the algorithmic trading plataform MetaTrader 5.

This bot works using the moving average crossover strategy.
In this strategy, the bot calculates two moving averages 
over the given price, per default the price used is the closing 
price for the period.

When the short-term moving average crosses above the long-term 
average, the bot closes its current position and issues a buy order
with the given stop loss and take profit margins.

Similary, when the short-term moving average crosses under the long-term 
average, the bot closes its current position and issues a sell order.

The user can change several parameters like the periods of the averages,
the price used, the type of average, the stop loss and take profit margins
and the volume to be negociated.