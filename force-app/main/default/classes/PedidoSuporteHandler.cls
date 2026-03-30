public with sharing class PedidoSuporteHandler {
    public void beforeUpdate(List<PedidoSuporte__c> newList, Map<Id, PedidoSuporte__c> oldMap) {
        validarInteracaoAgente(newList, oldMap);
    }

    public void validarInteracaoAgente(
        List<PedidoSuporte__c> newList,
        Map<Id, PedidoSuporte__c> oldMap
    ) {

        Set<Id> pedidosParaValidar = new Set<Id>();

        for (PedidoSuporte__c novo : newList) {
            PedidoSuporte__c antigo = oldMap.get(novo.Id);

            if (
                novo.Prioridade__c == 'Alta' &&
                novo.Status__c == 'Resolvido' &&
                antigo.Status__c != 'Resolvido'
            ) {
                pedidosParaValidar.add(novo.Id);
            }
        }

        if (pedidosParaValidar.isEmpty()) return;

        Set<Id> pedidosComInteracao = new Set<Id>();

        for (AggregateResult ar : [
            SELECT PedidoSuporte__c pedidoId
            FROM Interacao__c
            WHERE PedidoSuporte__c IN :pedidosParaValidar
            AND Tipo__c = 'Agente'
            GROUP BY PedidoSuporte__c
        ]) {
            pedidosComInteracao.add((Id) ar.get('pedidoId'));
        }

        for (PedidoSuporte__c novo : newList) {
            if (pedidosParaValidar.contains(novo.Id)) {
                if (!pedidosComInteracao.contains(novo.Id)) {
                    novo.addError(
                        'Pedidos de alta prioridade devem possuir pelo menos uma interação de agente antes de serem resolvidos.'
                    );
                }
            }
        }
    }
}