public class ProcessaInteracaoPedidoSuporteBatch implements Database.Batchable<SObject>, Database.Stateful {
    private static String STATUS_AGUARDANDO_CLIENTE = 'Aguardando Cliente';
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status__c, UltimaInteracao__c, Cliente__r.Email__c
            FROM PedidoSuporte__c
            WHERE UltimaInteracao__c < :System.now().addDays(-3)
            AND Status__c != :STATUS_AGUARDANDO_CLIENTE
        ]);
    }

    public void execute(Database.BatchableContext bc, List<PedidoSuporte__c> scope) {

        List<PedidoSuporte__c> pedidosParaAtualizar = new List<PedidoSuporte__c>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (PedidoSuporte__c pedido : scope) {

            pedido.Status__c = STATUS_AGUARDANDO_CLIENTE;
            pedidosParaAtualizar.add(pedido);

            String emailCliente = pedido.Cliente__r.Email__c;

            if (emailCliente != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                mail.setToAddresses(new List<String>{ emailCliente });
                mail.setSubject('Seu pedido será fechado em breve');
                mail.setPlainTextBody(
                    'Olá,\n\nSeu pedido de suporte está sem interação há mais de 3 dias e será fechado em breve caso não haja retorno.\n\nAtenciosamente.'
                );

                emails.add(mail);
            }
        }

        if (!pedidosParaAtualizar.isEmpty()) {
            update pedidosParaAtualizar;
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}