.. index::
   single: Instalando e Configurando o Symfony

Instalando e Configurando o Symfony Framework
=============================================

.. admonition:: Screencast
    :class: screencast

    Você prefere tutoriais em vídeo? Confira a série de screencasts
    `Stellar Development with Symfony`_.

.. _symfony-tech-requirements:

Requisitos Técnicos
-------------------

Antes de criar sua primeira aplicação Symfony, você deve:

* Instalar o PHP 7.2.9 ou superior e estas extensões PHP (que são instaladas e
  habilitadas por padrão na maioria das instalações do PHP 7): `Ctype`_, `iconv`_, `JSON`_,
  `PCRE`_, `Session`_, `SimpleXML`_ e `Tokenizer`_;
* `Instalar o Composer`_, que é usado para instalar pacotes PHP;
* `Instalar o Symfony`_, que cria no seu computador um binário chamado ``symfony``
  que fornece todas as ferramentas necessárias para desenvolver sua aplicação localmente.

O binário ``symfony`` fornece uma ferramenta para verificar se o seu computador atende a esses
requisitos. Abra o terminal do console e execute este comando:

.. code-block:: terminal

    $ symfony check:requirements

.. _creating-symfony-applications:

Criando Aplicações Symfony
--------------------------

Abra o terminal do console e execute qualquer um destes comandos para criar uma nova aplicação
Symfony:

.. code-block:: terminal

    # execute isso se você estiver criando uma aplicação web tradicional
    $ symfony new meu-projeto --full

    # execute isso se você estiver criando um microsserviço, uma aplicação de console ou uma API
    $ symfony new meu-projeto

A única diferença entre esses dois comandos é o número de pacotes
instalados por padrão. A opção ``--full`` instala todos os pacotes que você
normalmente precisa para criar aplicações web, então o tamanho da instalação será maior.

Se você não pode ou não quer `instalar o Symfony`_ por qualquer motivo, execute estes
comandos para criar a nova aplicação Symfony usando o Composer:

.. code-block:: terminal

    # execute isso se você estiver criando uma aplicação web tradicional
    $ composer create-project symfony/website-skeleton meu-projeto

    # execute isso se você estiver criando um microsserviço, uma aplicação de console ou uma API
    $ composer create-project symfony/skeleton meu-projeto

Não importa qual comando você executa para criar a aplicação Symfony. Todos eles
irão criar um novo diretório ``meu-projeto/``, baixar algumas dependências
nele e até gerar os diretórios e arquivos básicos que você precisará para
começar. Em outras palavras, sua nova aplicação está pronta!

.. note::

    Os diretórios de cache e logs do projeto (por padrão, ``<projeto>/var/cache/``
    e ``<projeto>/var/log/``) devem ter permissão de escrita para o servidor web. Se você tiver
    algum problema, leia como :doc:`configurar permissões para aplicações Symfony </setup/file_permissions>`.

Executando Aplicações Symfony
-----------------------------

Em produção você deve usar um servidor web como o Nginx ou o Apache (veja como
:doc:`configurar um servidor web para executar o Symfony </setup/web_server_configuration>`).
Mas para desenvolvimento é mais conveniente usar o
:doc:`servidor web local </setup/symfony_server>` fornecido pelo Symfony.

Este servidor local fornece suporte para HTTP/2, TLS/SSL, geração automática de
certificados de segurança e muitos outros recursos. Ele funciona com qualquer aplicação PHP,
não apenas projetos Symfony, por isso é uma ferramenta de desenvolvimento muito útil.

Abra o terminal do console, vá para o diretório do seu novo projeto e inicie o
servidor web local da seguinte maneira:

.. code-block:: terminal

    $ cd meu-projeto/
    $ symfony server:start

Abra seu navegador e acesse ``http://localhost:8000/``. Se tudo estiver
funcionando, você verá uma página de boas-vindas. Mais tarde, quando você terminar de trabalhar, pare
o servidor pressionando ``Ctrl+C`` a partir do seu terminal.

.. _install-existing-app:

Configurando um Projeto Symfony Existente
-----------------------------------------

Além de criar novos projetos Symfony, você também irá trabalhar em projetos
já criados por outros desenvolvedores. Nesse caso, você só precisa obter o
código do projeto e instalar as dependências com o Composer. Supondo que sua equipe usa
o Git, configure seu projeto com os seguintes comandos:

.. code-block:: terminal

    # clona o projeto para baixar seu conteúdo
    $ cd projetos/
    $ git clone ...

    # usa o Composer para instalar as dependências do projeto em vendor/
    $ cd meu-projeto/
    $ composer install

Você provavelmente também precisará customizar seu :ref:`arquivo .env <config-dot-env>`
e executar algumas outras tarefas específicas do projeto (por exemplo, criar um banco de dados). qq.. code-block:: terminal

    $ php bin/console about

.. _symfony-flex:

Instalando Pacotes
------------------

Uma prática comum ao desenvolver aplicações Symfony é instalar pacotes
(chamados de :doc:`bundles </bundles>`) que fornecem recursos
prontos para uso. Pacotes geralmente requerem alguma configuração antes de usá-los (editar algum
arquivo para habilitar o bundle, criar algum arquivo para adicionar uma configuração inicial, etc.)

Na maioria das vezes essa configuração pode ser automatizada e é por isso que o Symfony inclui o
`Symfony Flex`_, uma ferramenta para simplificar a instalação/remoção de pacotes em
aplicações Symfony. Tecnicamente falando, o Symfony Flex é um plug-in do Composer
instalado por padrão ao criar uma nova aplicação Symfony e que
**automatiza as tarefas mais comuns das aplicações Symfony**.

.. tip::

    Você também pode :doc:`adicionar o Symfony Flex a um projeto existente </setup/flex>`.

O Symfony Flex modifica o comportamento dos comandos ``require``, ``update``, e
``remove`` do Composer para fornecer recursos avançados. Considere o
seguinte exemplo:

.. code-block:: terminal

    $ cd meu-projeto/
    $ composer require logger

Se você executar esse comando em uma aplicação Symfony que não usa o Flex,
você verá um erro do Composer explicando que ``logger`` não é um nome de pacote
válido. Entretanto, se a aplicação tiver o Symfony Flex instalado, esse comando
instala e habilita todos os pacotes necessários para usar o logger oficial do Symfony.

Isso é possível porque muitos pacotes/bundles do Symfony definem **"receitas"**,
que são um conjunto de instruções automatizadas para instalar e habilitar pacotes em
aplicações Symfony. O Flex mantém o controle das receitas que ele instalou em um
arquivo ``symfony.lock``, que deve ser comitado no seu repositório de código.

As receitas do Symfony Flex são contribuídas pela comunidade e são armazenadas em
dois repositórios públicos:

* `Repositório de receitas principal`_, é uma lista com curadoria de receitas para pacotes mantidos
  de alta qualidade. O Symfony Flex só procura neste repositório por padrão.

* `Repositório de receitas contribuídas`_, contém todas as receitas criadas pela
  comunidade. Todas elas têm garantia de funcionamento, mas os pacotes associados a elas
  podem não ser mantidos. O Symfony Flex solicitará sua permissão antes de instalar
  qualquer uma destas receitas.

Leia a `documentação das Receitas do Symfony`_ para aprender tudo sobre como
criar receitas para seus próprios pacotes.

.. _symfony-packs:

Packs do Symfony
~~~~~~~~~~~~~~~~

Às vezes, um único recurso requer a instalação de vários pacotes e bundles.
Em vez de instalá-los individualmente, o Symfony fornece **packs**, que são
metapacotes do Composer que incluem várias dependências.

Por exemplo, para adicionar recursos de depuração na sua aplicação você pode executar o
comando ``composer require --dev debug``. Isso instala o ``symfony/debug-pack``,
que por sua vez instala vários pacotes como ``symfony/debug-bundle``,
``symfony/monolog-bundle``, ``symfony/var-dumper``, etc.

Por padrão, ao instalar packs do Symfony o arquivo ``composer.json`` mostra a
dependência do pack (por exemplo, ``"symfony/debug-pack": "^1.0"``) em vez dos verdadeiros pacotes
instalados. Para mostrar os pacotes, adicione a opção ``--unpack`` ao
instalar um pack (por exemplo, ``composer require debug --dev --unpack``) ou execute este
comando para descompactar os packs já instalados: ``composer unpack NOME_DO_PACK``
(por exemplo, ``composer unpack debug``).

.. _security-checker:

Verificando Vulnerabilidades de Segurança
-----------------------------------------

O binário ``symfony`` criado quando você `instala o Symfony`_ fornece um comando para
verificar se as dependências do seu projeto contêm qualquer vulnerabilidade de segurança
conhecida:

.. code-block:: terminal

    $ symfony check:security

Uma boa prática de segurança é executar esse comando regularmente para poder
atualizar ou substituir dependências comprometidas o mais rápido possível. A verificação
de segurança é feita localmente clonando o `banco de dados público de avisos de segurança do PHP`_,
para que seu arquivo ``composer.lock`` não seja enviado para a rede.

.. tip::

    O comando ``check:security`` termina com um código de saída diferente de zero se
    qualquer uma das suas dependências for afetada por uma vulnerabilidade de segurança conhecida.
    Desta forma, você pode adicioná-lo ao processo de construção do seu projeto e aos seus fluxos de
    integração contínua para fazê-los falhar quando houver vulnerabilidades.

Versões LTS do Symfony
----------------------

De acordo com o :doc:`processo de lançamento do Symfony </contributing/community/releases>`,
as versões de "suporte a longo prazo" (ou LTS) são publicadas a cada dois anos.
Confira o `calendário de lançamento do Symfony`_ para saber qual é a versão LTS mais recente.

Por padrão, o comando que cria novas aplicações Symfony usa a versão
estável mais recente. Se você quer usar uma versão LTS, adicione a opção ``--version``:

.. code-block:: terminal

    # usa a versão LTS mais recente
    $ symfony new meu-projeto --version=lts

    # usa a próxima versão do Symfony a ser lançada (ainda em desenvolvimento)
    $ symfony new meu-projeto --version=next

A Aplicação Symfony Demo
--------------------------------------

`A Aplicação Symfony Demo`_ é uma aplicação totalmente funcional que mostra a
maneira recomendada de desenvolver aplicações Symfony. É uma ótima ferramenta de aprendizado para
os iniciantes no Symfony e seu código contém toneladas de comentários e notas úteis.

Execute este comando para criar um novo projeto baseado na aplicação Symfony Demo:

.. code-block:: terminal

    $ symfony new meu-projeto --demo

Comece a Codar!
---------------

Passada a instalação, é hora de :doc:`Criar sua primeira página no Symfony </page_creation>`.

Aprenda Mais
------------

.. toctree::
    :hidden:

    page_creation

.. toctree::
    :maxdepth: 1
    :glob:

    setup/homestead
    setup/web_server_configuration
    setup/*

.. _`Stellar Development with Symfony`: https://symfonycasts.com/screencast/symfony
.. _`Instalar o Composer`: https://getcomposer.org/download/
.. _`Instalar o Symfony`: https://symfony.com/download
.. _`instalar o Symfony`: https://symfony.com/download
.. _`instala o Symfony`: https://symfony.com/download
.. _`A Aplicação Symfony Demo`: https://github.com/symfony/demo
.. _`Symfony Flex`: https://github.com/symfony/flex
.. _`banco de dados público de avisos de segurança do PHP`: https://github.com/FriendsOfPHP/security-advisories
.. _`calendário de lançamento do Symfony`: https://symfony.com/roadmap
.. _`Repositório de receitas principal`: https://github.com/symfony/recipes
.. _`Repositório de receitas contribuídas`: https://github.com/symfony/recipes-contrib
.. _`documentação das Receitas do Symfony`: https://github.com/symfony/recipes/blob/master/README.rst
.. _`iconv`: https://php.net/book.iconv
.. _`JSON`: https://php.net/book.json
.. _`Session`: https://php.net/book.session
.. _`Ctype`: https://php.net/book.ctype
.. _`Tokenizer`: https://php.net/book.tokenizer
.. _`SimpleXML`: https://php.net/book.simplexml
.. _`PCRE`: https://php.net/book.pcre
