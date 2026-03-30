trigger PedidoSuporteTrigger on PedidoSuporte__c (before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        PedidoSuporteHandler handler = new PedidoSuporteHandler();
        handler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
}