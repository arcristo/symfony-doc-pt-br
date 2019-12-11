A Visão Geral
=============

Comece a usar o Symfony em 10 minutos! Sério! É tudo que você precisa para entender os
conceitos mais importantes e começar a construir um projeto real!

Se você já usou um framework web antes, deve se sentir em casa com
o Symfony. Caso contrário, seja bem-vinda a uma maneira totalmente nova de desenvolver aplicações web. O Symfony
*abraça* as melhores práticas, mantém a compatibilidade com versões anteriores (Sim! A atualização é sempre
fácil e segura!) e oferece suporte a longo prazo.

.. _installing-symfony2:

Baixando o Symfony
------------------

Primeiro, verifique se você instalou o `Composer`_ e possui o PHP 7.1.3 ou superior.

Preparada? Em um terminal, execute:

.. code-block:: terminal

    $ composer create-project symfony/skeleton quick_tour

Isso cria um novo diretório ``quick_tour/`` com uma pequena, mas poderosa nova
aplicação Symfony:

.. code-block:: text

    quick_tour/
    ├─ .env
    ├─ bin/console
    ├─ composer.json
    ├─ composer.lock
    ├─ config/
    ├─ public/index.php
    ├─ src/
    ├─ symfony.lock
    ├─ var/
    └─ vendor/

Já podemos carregar o projeto em um navegador? Sim! Você pode configurar
:doc:`o Nginx ou o Apache </setup/web_server_configuration>` e configurar o
diretório público (document root) para ser o diretório ``public/``. Mas, para desenvolvimento, é melhor
:doc:`instalar o servidor web local Symfony </setup/symfony_server>` e executá-lo
da seguinte maneira:

.. code-block:: terminal

    $ symfony server:start

Teste sua nova aplicação acessando ``http://localhost:8000`` em um navegador!

.. image:: /_images/quick_tour/no_routes_page.png
   :align: center
   :class: with-browser

Fundamentos: Rota, Controlador, Resposta
----------------------------------------

Nosso projeto tem apenas uns 15 arquivos, mas está pronto para se tornar uma elegante API, uma
aplicação web robusta, ou um microsserviço. Symfony começa pequeno, mas escala com você.

Mas antes de irmos longe demais, vamos nos aprofundar nos fundamentos construindo nossa primeira página.

Comece em ``config/routes.yaml``: aqui é onde *nós* podemos definir o URL para nossa nova
página. Remova o comentário do exemplo que já está no arquivo:

.. code-block:: yaml

    # config/routes.yaml
    index:
        path: /
        controller: 'App\Controller\DefaultController::index'

Isso é uma *rota*: ela define o URL da sua página (``/``) e o "controlador":
a *função* que será chamada sempre que alguém acessar esse URL. Essa função
não existe ainda, então vamos criá-la!

Em ``src/Controller``, crie uma nova classe ``DefaultController`` e um método ``index``
dentro::

    // src/Controller/DefaultController.php
    namespace App\Controller;

    use Symfony\Component\HttpFoundation\Response;

    class DefaultController
    {
        public function index()
        {
            return new Response('Olá!');
        }
    }

É isso aí! Tente ir para a página inicial: ``http://localhost:8000/``. O Symfony vê
que o URL corresponde à nossa rota e então executa o novo método ``index()``.

Um controlador é apenas uma função normal com *uma* regra: ela deve retornar um objeto
Symfony ``Response``. Mas essa resposta pode conter qualquer coisa: texto simples, JSON ou
uma página HTML completa.

Mas o sistema de roteamento é *muito* mais poderoso. Então vamos tornar a rota mais interessante:

.. code-block:: diff

    # config/routes.yaml
    index:
    -     path: /
    +     path: /hello/{name}
        controller: 'App\Controller\DefaultController::index'

O URL desta página mudou: ele *agora* é ``/hello/*``: o ``{name}`` funciona
como um curinga que corresponde a qualquer coisa. E fica melhor! Atualize o controlador também:

.. code-block:: diff

    // src/Controller/DefaultController.php
    namespace App\Controller;

    use Symfony\Component\HttpFoundation\Response;

    class DefaultController
    {
    -     public function index()
    +     public function index($name)
        {
    -         return new Response('Olá!');
    +         return new Response("Olá $name!");
        }
    }

Teste a página acessando ``http://localhost:8000/hello/Symfony``. Você deve
ver: Olá Symfony! O valor do ``{name}`` no URL está disponível como um argumento ``$name``
no seu controlador.

Mas isso pode ser ainda mais simples! Então vamos instalar o suporte a anotações:

.. code-block:: terminal

    $ composer require annotations

Agora, comente a rota YAML adicionando o caractere ``#``:

.. code-block:: yaml

    # config/routes.yaml
    # index:
    #     path: /hello/{name}
    #     controller: 'App\Controller\DefaultController::index'

Em vez disso, adicione a rota *logo acima* do método do controlador:

.. code-block:: diff

    // src/Controller/DefaultController.php
    namespace App\Controller;

    use Symfony\Component\HttpFoundation\Response;
    + use Symfony\Component\Routing\Annotation\Route;

    class DefaultController
    {
    +    /**
    +     * @Route("/hello/{name}")
    +     */
         public function index($name) {
             // ...
         }
    }

Isso funciona exatamente como antes! Mas ao usar anotações, a rota e o controlador
ficam próximos um do outro. Precisa de outra página? Adicione outra rota e método
no ``DefaultController``::

    // src/Controller/DefaultController.php
    namespace App\Controller;

    use Symfony\Component\HttpFoundation\Response;
    use Symfony\Component\Routing\Annotation\Route;

    class DefaultController
    {
        // ...

        /**
         * @Route("/simplicity")
         */
        public function simple()
        {
            return new Response('Simples! Fácil! Ótimo!');
        }
    }

O roteamento pode fazer *ainda* mais, mas guardaremos isso para outra hora! No momento, nossa
aplicação precisa de mais recursos! Como um mecanismo de template, ferramentas de log, ferramentas de depuração e muito mais.

Continue lendo com :doc:`/quick_tour/flex_recipes`.

.. _`Composer`: https://getcomposer.org/
