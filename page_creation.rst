.. index::
   single: Crie sua Primeira Página no Symfony

.. _creating-pages-in-symfony2:
.. _creating-pages-in-symfony:

Crie sua Primeira Página no Symfony
===================================

Criar uma nova página - seja uma página HTML ou um endpoint JSON - é um
processo de duas etapas:

#. **Crie uma rota**: Uma rota é o URL (por exemplo, ``/about``) da sua página e
   aponta para um controller;

#. **Crie um controller**: Um controller é a função PHP que você escreve que
   cria a página. Você pega as informações da requisição recebida e as usa para
   criar um objeto Symfony ``Response``, que pode conter conteúdo HTML, uma string
   JSON ou até mesmo um arquivo binário como uma imagem ou PDF.

.. admonition:: Screencast
    :class: screencast

    Você prefere tutoriais em vídeo? Confira a série de screencasts
    `Stellar Development with Symfony`_.

.. seealso::

    O Symfony *abraça* o ciclo de vida de requisição e resposta do HTTP. Para saber mais
    consulte :doc:`/introduction/http_fundamentals`.

.. index::
   single: Criação de Página; Exemplo

Criando uma Página: Rota e Controller
-------------------------------------

.. tip::

    Antes de continuar, verifique se você já leu o artigo sobre :doc:`Instalação </setup>`
    e pode acessar sua nova aplicação Symfony no navegador.

Suponha que você queira criar uma página - ``/lucky/number`` - que gera um número da sorte
(na verdade, um número aleatório) e o imprime. Para fazer isso crie uma classe "Controller" e um
método "controller" dentro dela::

    <?php
    // src/Controller/LuckyController.php
    namespace App\Controller;

    use Symfony\Component\HttpFoundation\Response;

    class LuckyController
    {
        public function number()
        {
            $number = random_int(0, 100);

            return new Response(
                '<html><body>Número da sorte: '.$number.'</body></html>'
            );
        }
    }

Agora você precisa associar esta função controller a um URL público (por exemplo, ``/lucky/number``)
para que o método ``number()`` seja executado quando um usuário acessar este URL. Esta associação
é definida criando uma **rota** no arquivo ``config/routes.yaml``:

.. code-block:: yaml

    # config/routes.yaml

    # o nome da rota "app_lucky_number" ainda não é importante
    app_lucky_number:
        path: /lucky/number
        controller: App\Controller\LuckyController::number

É isso aí! Se você estiver usando o servidor web Symfony, teste a rota acessando:

    http://localhost:8000/lucky/number

Se você vir um número da sorte sendo impresso para você, parabéns! Mas antes de
correr para jogar na loteria, confira como isso funciona. Lembra das duas etapas
para criar uma página?

#. *Crie uma rota*: Em ``config/routes.yaml`` a rota define o URL da sua
   página (``path``) e qual ``controller`` chamar. Você aprenderá mais sobre :doc:`roteamento </routing>`
   em sua própria seção, incluindo como criar URLs *variáveis*;

#. *Crie um controller*: É uma função onde *você* cria a página e, finalmente,
   retorna um objeto ``Response``. Você aprenderá mais sobre :doc:`controllers </controller>`
   em sua própria seção, incluindo como retornar respostas JSON.

.. _annotation-routes:

Rotas de Anotação
-----------------

Em vez de definir sua rota em YAML, o Symfony também permite que você use rotas de
*anotação*. Para fazer isso instale o pacote de anotações:

.. code-block:: terminal

    $ composer require annotations

Agora você pode adicionar sua rota diretamente *acima* do controller:

.. code-block:: diff

    // src/Controller/LuckyController.php

    // ...
    + use Symfony\Component\Routing\Annotation\Route;

    class LuckyController
    {
    +     /**
    +      * @Route("/lucky/number")
    +      */
        public function number()
        {
            // isso continua o mesmo
        }
    }

É isso aí! A página - ``http://localhost:8000/lucky/number`` funcionará exatamente
como antes! As anotações são a maneira recomendada de configurar rotas.

.. _flex-quick-intro:

Instalação Automática de Receitas com o Symfony Flex
----------------------------------------------------

Você pode não ter percebido, mas quando você executou ``composer require annotations``, duas
coisas incríveis aconteceram, ambas graças a um poderoso plug-in do Composer chamado
:ref:`Flex <symfony-flex>`.

Primeiro, ``annotations`` não é um nome real de pacote: é um *alias* (ou seja, um atalho)
que o Flex resolve para ``sensio/framework-extra-bundle``.

Segundo, após o download deste pacote, o Flex executou uma *receita*, que é um
conjunto de instruções automatizadas que diz ao Symfony como integrar um pacote
externo. Existem `receitas do Flex`_ para muitos pacotes e elas têm a habilidade
de fazer muita coisa, como adicionar arquivos de configuração, criar diretórios, atualizar o ``.gitignore``
e adicionar novas configurações ao seu arquivo ``.env``. O Flex *automatiza* a instalação de
pacotes para que você possa voltar a codar.

O Comando bin/console
---------------------

Seu projeto já possui uma poderosa ferramenta de depuração: o comando ``bin/console``.
Tente executá-lo:

.. code-block:: terminal

    $ php bin/console

Você deve ver uma lista de comandos que podem fornecer informações sobre depuração, ajudar a gerar
código, gerar migrações de banco de dados e muito mais. Ao instalar mais pacotes
você verá mais comandos.

Para obter uma lista de *todas* as rotas no seu sistema use o comando ``debug:router``:

.. code-block:: terminal

    $ php bin/console debug:router

Você deve ver a sua rota ``app_lucky_number`` no topo da lista:

================== ======== ======== ====== ===============
 Name               Method   Scheme   Host   Path
================== ======== ======== ====== ===============
 app_lucky_number   ANY      ANY      ANY    /lucky/number
================== ======== ======== ====== ===============

Você também verá rotas de depuração abaixo de ``app_lucky_number`` -- veremos mais sobre
as rotas de depuração na próxima seção.

Você aprenderá sobre muitos outros comandos à medida que continua!

A Barra de Ferramentas de Depuração Web: Sonho de Depuração
-----------------------------------------------------------

Um dos *principais* recursos do Symfony é a Barra de Ferramentas de Depuração Web: uma barra que exibe
uma *enorme* quantidade de informações de depuração na parte inferior da página durante
o desenvolvimento. Tudo isso é incluído pronto para uso usando um :ref:`pack do Symfony <symfony-packs>`
chamado ``symfony/profiler-pack``.

Você verá uma barra preta na parte inferior da página. Você aprenderá mais sobre todas as informações que ela contém
ao longo do caminho, mas sinta-se à vontade para experimentar: passe o mouse e clique
nos diferentes ícones para obter informações sobre roteamento, desempenho, logging e muito mais.

Renderizando um Template
------------------------

Se você estiver retornando HTML do seu controller, provavelmente vai querer renderizar
um template. Felizmente, o Symfony vem com o `Twig`_: uma linguagem de templating
fácil, poderosa e realmente divertida.

Instale o pacote twig com:

.. code-block:: terminal

    $ composer require twig

Certifique-se de que ``LuckyController`` extende a classe base
:class:`Symfony\\Bundle\\FrameworkBundle\\Controller\\AbstractController` do Symfony:

.. code-block:: diff

    // src/Controller/LuckyController.php

    // ...
    + use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

    - class LuckyController
    + class LuckyController extends AbstractController
    {
        // ...
    }

Agora use a conveniente função ``render()`` para renderizar um template. Passe uma variável
``number`` para que você possa usá-la no Twig::

    // src/Controller/LuckyController.php
    namespace App\Controller;

    // ...
    class LuckyController extends AbstractController
    {
        /**
         * @Route("/lucky/number")
         */
        public function number()
        {
            $number = random_int(0, 100);

            return $this->render('lucky/number.html.twig', [
                'number' => $number,
            ]);
        }
    }

Os arquivos de template ficam no diretório ``templates/``, criado automaticamente para você
quando você instalou o Twig. Crie um novo diretório ``templates/lucky`` com um novo
arquivo ``number.html.twig`` dentro:

.. code-block:: html+twig

    {# templates/lucky/number.html.twig #}
    <h1>Seu número da sorte é {{ number }}</h1>

A sintaxe ``{{ number }}`` é usada para *imprimir* variáveis no Twig. Atualize seu navegador
para obter seu *novo* número da sorte!

    http://localhost:8000/lucky/number

Agora você pode se perguntar para onde foi a Barra de Ferramentas de Depuração Web: isso acontece porque não
existe uma tag ``</body>`` no template atual. Você mesmo pode adicionar o elemento body,
ou pode extender ``base.html.twig``, que contém todos os elementos HTML padrão.

No artigo sobre :doc:`templates </templates>` você aprenderá tudo sobre o Twig: como
fazer loop, renderizar outros templates e aproveitar seu poderoso sistema de herança de layout.

Conferindo a Estrutura do Projeto
---------------------------------

Ótimas notícias! Você já trabalhou nos diretórios mais importantes do seu
projeto:

``config/``
    Contém... configurações! Você irá configurar rotas,
    :doc:`serviços </service_container>` e pacotes.

``src/``
    Todo o seu código PHP fica aqui.

``templates/``
    Todos os seus templates Twig ficam aqui.

Na maioria das vezes você irá trabalhar em ``src/``, ``templates/`` ou ``config/``.
Enquanto continua lendo, você aprenderá o que pode ser feito em cada um destes diretórios.

E os outros diretórios do projeto?

``bin/``
    O famoso arquivo ``bin/console`` fica aqui (e outros arquivos executáveis
    menos importantes).

``var/``
    É aqui que os arquivos criados automaticamente são armazenados, como arquivos de cache
    (``var/cache/``) e logs (``var/log/``).

``vendor/``
    As bibliotecas de terceiros (ou seja, "vendor") ficam aqui! Elas são baixadas através do gerenciador
    de pacotes `Composer`_.

``public/``
    Este é o diretório público do seu projeto: você coloca todos os arquivos acessíveis ao público
    aqui.

E quando você instalar novos pacotes, novos diretórios serão criados automaticamente
quando necessário.

O Que Vem a Seguir?
-------------------

Parabéns! Você já está começando a dominar o Symfony e a aprender uma nova
maneira de criar aplicações bonitas, funcionais, rápidas e de fácil manutenção.

Certo, é hora de terminar de dominar os fundamentos lendo estes artigos:

* :doc:`/routing`
* :doc:`/controller`
* :doc:`/templates`
* :doc:`/configuration`

Em seguida, aprenda sobre outros tópicos importantes como o
:doc:`container de serviços </service_container>`,
o :doc:`sistema de formulários </forms>`, como usar o :doc:`Doctrine </doctrine>`
(se você precisar consultar um banco de dados) e muito mais!

Divirta-se!

Vá mais Fundo com os Fundamentos do HTTP e do Framework
-------------------------------------------------------

.. toctree::
    :hidden:

    routing

.. toctree::
    :maxdepth: 1
    :glob:

    introduction/*

.. _`Twig`: https://twig.symfony.com
.. _`Composer`: https://getcomposer.org
.. _`Stellar Development with Symfony`: https://symfonycasts.com/screencast/symfony/setup
.. _`receitas do Flex`: https://flex.symfony.com
