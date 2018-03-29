Panorama Geral
==============

Comece a usar o Symfony em 10 minutos! Mesmo! Isso é tudo que você precisa para entender os
conceitos mais importantes e começar a construir um projeto real!

Se você já usou um framework web antes, você deve se sentir em casa com
o Symfony. Se não, bem-vindo a uma nova forma de desenvolver aplicações web. O Symfony
*abraça* as melhores práticas, mantém compatibilidade com versões anteriores (Sim! A atualização é sempre
segura e fácil!) e oferece suporte a longo prazo.

.. _installing-symfony2:

Baixando o Symfony
------------------

Primeiro, certifique-se de ter instalado o `Composer`_ e ter o PHP 7.1.3 ou superior.

Pronto? Em um terminal, execute:

.. code-block:: terminal

    $ composer create-project symfony/skeleton guia_rapido

Isso cria um novo diretório ``guia_rapido/`` com uma pequena mas poderosa nova
aplicação Symfony:

.. code-block:: text

    guia_rapido/
    ├─ .env
    ├─ .env.dist
    ├─ bin/console
    ├─ composer.json
    ├─ composer.lock
    ├─ config/
    ├─ public/index.php
    ├─ src/
    ├─ symfony.lock
    ├─ var/
    └─ vendor/

Já podemos carregar o projeto em um navegador? Claro! Você pode configurar
:doc:`o Nginx ou o Apache </setup/web_server_configuration>` e configurar o document
root para ser o diretório ``public/``. Mas, para desenvolvimento, o Symfony possui seu próprio servidor.
Instale e execute-o com:

.. code-block:: terminal

    $ composer require server --dev
    $ php bin/console server:start

Teste sua nova aplicação acessando ``http://localhost:8000`` em um navegador!

.. image:: /_images/quick_tour/no_routes_page.png
   :align: center
   :class: with-browser

Fundamentos: Rota, Controller, Resposta
---------------------------------------

Nosso projeto tem apenas cerca de 15 arquivos, mas está pronto para se tornar uma API elegante, uma aplicação
web robusta ou um microsserviço. O Symfony começa pequeno, mas escala com você.

Mas antes de irmos muito longe, vamos nos aprofundar nos fundamentos construindo nossa primeira página.

Comece em ``config/routes.yaml``: aqui é onde *nós* podemos definir o URL para nossa nova
página. Descomente o exemplo que já existe no arquivo:

.. code-block:: yaml

    index:
        path: /
        controller: 'App\Controller\DefaultController::index'

Isso é uma *rota*: ela define o URL para sua página (``/``) e o "controller":
a *função* que será chamada sempre que alguém acessar esse URL. Essa função
ainda não existe, então vamos criá-la!

Em ``src/Controller``, crie uma nova classe ``DefaultController`` e um método ``index``
dentro::

    namespace App\Controller;

    use Symfony\Component\HttpFoundation\Response;

    class DefaultController
    {
        public function index()
        {
            return new Response('Olá!');
        }
    }

É isso aí! Tente acessar a página inicial: ``http://localhost:8000/``. O Symfony vê
que o URL corresponde à nossa rota e então executa o novo método ``index()``.

Um controller é apenas uma função normal com *uma* regra: ele deve retornar um objeto
``Response`` do Symfony. Mas essa resposta pode conter qualquer coisa: texto simples, JSON ou
uma página HTML completa.

Mas o sistema de roteamento é *muito* mais poderoso. Então, vamos tornar a rota mais interessante:

.. code-block:: diff

    # config/routes.yaml
    index:
    -     path: /
    +     path: /ola/{name}
        controller: 'App\Controller\DefaultController::index'

O URL para esta página mudou: ele *agora* é ``/ola/*``: o ``{name}`` age
como um curinga que corresponde a qualquer coisa. E ainda tem mais! Atualize o controller também:

.. code-block:: diff

    // src/Controller/DefaultController.php
    // ...

    - public function index()
    + public function index($name)
    {
    -     return new Response('Olá!');
    +     return new Response("Olá $name!");
    }

Teste a página acessando ``http://localhost:8000/ola/Symfony``. Você deve
ver: Olá Symfony! O valor de ``{name}`` no URL está disponível como um argumento ``$name``
no seu controller.

Mas isso pode ser ainda mais simples! Então vamos instalar o suporte a annotations:

.. code-block:: terminal

    $ composer require annotations

Agora, comente a rota YAML adicionando o caractere ``#``:

.. code-block:: yaml

    # config/routes.yaml
    # index:
    #     path: /ola/{name}
    #     controller: 'App\Controller\DefaultController::index'

Em vez disso, adicione a rota *logo acima* do método controller:

.. code-block:: diff

    // src/Controller/DefaultController.php
    // ...

    + use Symfony\Component\Routing\Annotation\Route;

    + /**
    +  * @Route("/ola/{name}")
    +  */
    public function index($name)

Isso funciona exatamente como antes! Mas usando annotations, a rota e o controller
vivem lado a lado. Precisa de outra página? Basta adicionar outra rota e método
no ``DefaultController``::

    // src/Controller/DefaultController.php
    // ...

    /**
     * @Route("/simplicidade")
     */
    public function simple()
    {
        return new Response('Simples! Fácil! Ótimo!');
    }

O roteamento pode fazer *ainda* mais, mas vamos guardar isso para outra hora! No momento, nossa
aplicação precisa de mais recursos! Como um engine de template, logging, ferramentas de depuração e muito mais.

Continue lendo com :doc:`/quick_tour/flex_recipes`.

.. _`Composer`: https://getcomposer.org/
