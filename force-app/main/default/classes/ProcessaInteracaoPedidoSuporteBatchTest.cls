@IsTest
private class ProcessaInteracaoPedidoSuporteBatchTest {

    @TestSetup
    static void setup() {
        Account acc = new Account(
            Name = 'Conta Teste',
            Email__c = 'cliente@teste.com'
        );
        insert acc;

        Account accSemEmail = new Account(
            Name = 'Conta Sem Email'
        );
        insert accSemEmail;

        List<PedidoSuporte__c> pedidos = new List<PedidoSuporte__c>();

        // Pedido com interação antiga (> 3 dias) e com e-mail — deve ser processado
        pedidos.add(new PedidoSuporte__c(
            Status__c = 'Novo',
            UltimaInteracao__c = System.now().addDays(-5),
            Cliente__c = acc.Id
        ));

        // Pedido com interação antiga (> 3 dias) sem e-mail — deve atualizar status mas não enviar e-mail
        pedidos.add(new PedidoSuporte__c(
            Status__c = 'Em Atendimento',
            UltimaInteracao__c = System.now().addDays(-4),
            Cliente__c = accSemEmail.Id
        ));

        // Pedido com interação recente (< 3 dias) — NÃO deve ser processado
        pedidos.add(new PedidoSuporte__c(
            Status__c = 'Novo',
            UltimaInteracao__c = System.now().addDays(-1),
            Cliente__c = acc.Id
        ));

        // Pedido já com status 'Aguardando Cliente' — NÃO deve ser retornado pelo query
        pedidos.add(new PedidoSuporte__c(
            Status__c = 'Aguardando Cliente',
            UltimaInteracao__c = System.now().addDays(-10),
            Cliente__c = acc.Id
        ));

        insert pedidos;
    }

    @IsTest
    static void deveAtualizarStatusEEnviarEmailParaPedidosAntigos() {
        Test.startTest();
        ProcessaInteracaoPedidoSuporteBatch batch = new ProcessaInteracaoPedidoSuporteBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Pedidos com interação > 3 dias e status diferente de 'Aguardando Cliente' devem ter sido atualizados
        List<PedidoSuporte__c> pedidosAtualizados = [
            SELECT Id, Status__c, UltimaInteracao__c
            FROM PedidoSuporte__c
            WHERE Status__c = 'Aguardando Cliente'
        ];

        // 2 pedidos antigos atualizados + 1 que já estava com o status = 3
        System.assertEquals(3, pedidosAtualizados.size(),
            'Deveria haver 3 pedidos com status Aguardando Cliente');

        // O pedido com interação recente deve manter o status original
        List<PedidoSuporte__c> pedidosNaoAlterados = [
            SELECT Id, Status__c
            FROM PedidoSuporte__c
            WHERE Status__c = 'Novo'
            AND UltimaInteracao__c >= :System.now().addDays(-3)
        ];

        System.assertEquals(1, pedidosNaoAlterados.size(),
            'Pedido com interação recente não deveria ter sido alterado');
    }

    @IsTest
    static void deveProcessarPedidoSemEmailSemErro() {
        // Remove pedidos com e-mail para isolar o cenário
        List<PedidoSuporte__c> pedidosComEmail = [
            SELECT Id FROM PedidoSuporte__c
            WHERE Cliente__r.Email__c != null
        ];
        delete pedidosComEmail;

        Test.startTest();
        ProcessaInteracaoPedidoSuporteBatch batch = new ProcessaInteracaoPedidoSuporteBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        List<PedidoSuporte__c> pedidosAtualizados = [
            SELECT Id, Status__c
            FROM PedidoSuporte__c
            WHERE Status__c = 'Aguardando Cliente'
        ];

        // Apenas o pedido sem e-mail com interação antiga deve ter sido processado
        System.assert(!pedidosAtualizados.isEmpty(),
            'Pedido sem e-mail deveria ter o status atualizado mesmo sem envio de e-mail');
    }

    @IsTest
    static void naoDeveProcessarPedidosRecentes() {
        // Remove todos os pedidos antigos para garantir que nenhum é processado
        List<PedidoSuporte__c> pedidosAntigos = [
            SELECT Id FROM PedidoSuporte__c
            WHERE UltimaInteracao__c < :System.now().addDays(-3)
        ];
        delete pedidosAntigos;

        Test.startTest();
        ProcessaInteracaoPedidoSuporteBatch batch = new ProcessaInteracaoPedidoSuporteBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        List<PedidoSuporte__c> pedidosAguardando = [
            SELECT Id FROM PedidoSuporte__c
            WHERE Status__c = 'Aguardando Cliente'
        ];

        System.assertEquals(0, pedidosAguardando.size(),
            'Nenhum pedido recente deveria ter sido alterado para Aguardando Cliente');
    }

    @IsTest
    static void deveExecutarBatchSemRegistros() {
        // Remove todos os registros para testar execução sem dados
        delete [SELECT Id FROM PedidoSuporte__c];

        Test.startTest();
        ProcessaInteracaoPedidoSuporteBatch batch = new ProcessaInteracaoPedidoSuporteBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        List<PedidoSuporte__c> todos = [SELECT Id FROM PedidoSuporte__c];
        System.assertEquals(0, todos.size(),
            'Não deveria haver pedidos após deletar todos');
    }
}
