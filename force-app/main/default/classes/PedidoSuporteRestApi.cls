@RestResource(urlMapping='/pedidos-suporte')
global with sharing class PedidoSuporteRestApi {

    global class PedidoSuporteRequest {
        global String clienteId;
        global String descricao;
        global String prioridade;
    }

    global class PedidoSuporteResponse {
        global String pedidoId;
    }

    @HttpPost
    global static PedidoSuporteResponse criarPedido() {
        RestRequest req = RestContext.request;
        PedidoSuporteRequest payload = (PedidoSuporteRequest) JSON.deserialize(
            req.requestBody.toString(),
            PedidoSuporteRequest.class
        );

        PedidoSuporte__c pedido = new PedidoSuporte__c(
            Cliente__c          = payload.clienteId,
            Descricao__c        = payload.descricao,
            Prioridade__c       = payload.prioridade,
            Status__c           = 'Novo',
            UltimaInteracao__c  = Datetime.now()
        );

        insert pedido;

        PedidoSuporteResponse res = new PedidoSuporteResponse();
        res.pedidoId = pedido.Id;
        return res;
    }
}
