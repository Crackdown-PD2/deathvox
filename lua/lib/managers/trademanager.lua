local fs_original_trademanager_sendbegintrade = TradeManager._send_begin_trade
function TradeManager:_send_begin_trade(criminal)
	if criminal then
		fs_original_trademanager_sendbegintrade(self, criminal)
	end
end
