global class ProcessaInteracaoPedidoSuporteSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ProcessaInteracaoPedidoSuporteBatch(), 200);
    }
}