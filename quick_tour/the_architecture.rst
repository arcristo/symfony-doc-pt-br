A Arquitetura
=============

Você é meu herói! Quem imaginaria que você ainda estaria aqui depois das duas
primeiras partes? Seus esforços serão bem recompensados em breve. As duas primeiras partes não contemplaram
muito profundamente a arquitetura do framework. Já que ela faz o Symfony destacar-se
na multidão de frameworks, vamos mergulhar na arquitetura agora.

Adicionando Logging
-------------------

Uma nova aplicação Symfony é micro: é basicamente apenas um sistema de roteamento e controller. Mas
graças ao Flex, instalar mais recursos é simples.

Quer um sistema de logging? Sem problemas:

.. code-block:: terminal

    $ composer require logger

Isso instala e configura (através de uma receita) a poderosa biblioteca `Monolog`_. Para
usar o logger em um controller, adicione um novo argumento do tipo ``LoggerInterface``::

    use Psr\Log\LoggerInterface;
    // ...

    public function index($name, LoggerInterface $logger)
    {
        $logger->info("Dizendo olá para $name!");

        // ...
    }

É isso aí! A nova mensagem de log será gravada em ``var/log/dev.log``. Claro, isso
pode ser configurado atualizando um dos arquivos de configuração adicionados pela receita.

Serviços e Autowiring
---------------------

Mas espere! Algo *muito* legal acabou de acontecer. O Symfony leu a declaração de tipo ``LoggerInterface``
e automaticamente descobriu que deveria nos passar o objeto Logger!
Isso é chamado *autowiring*.

Todo trabalho que é feito em uma aplicação Symfony é feito por um  *objeto*: o objeto
Logger registra coisas e o objeto Twig renderiza templates. Estes objetos são chamados de
*serviços* e são *ferramentas* que ajudam a criar recursos avançados.

Para tornar a vida incrível, você pode pedir ao Symfony para lhe passar um serviço usando uma declaração de tipo.
Quais outras possíveis classes ou interfaces você poderia usar? Descubra executando:

.. code-block:: terminal

    $ php bin/console debug:autowiring

=============================================================== =====================================
Class/Interface Type                                            Alias Service ID
=============================================================== =====================================
``Psr\Cache\CacheItemPoolInterface``                            alias for "cache.app.recorder"
``Psr\Log\LoggerInterface``                                     alias for "monolog.logger"
``Symfony\Component\EventDispatcher\EventDispatcherInterface``  alias for "debug.event_dispatcher"
``Symfony\Component\HttpFoundation\RequestStack``               alias for "request_stack"
``Symfony\Component\HttpFoundation\Session\SessionInterface``   alias for "session"
``Symfony\Component\Routing\RouterInterface``                   alias for "router.default"
=============================================================== =====================================

Este é apenas um breve resumo da lista completa! E à medida que você adiciona mais pacotes, essa
lista de ferramentas aumentará!

Criando Serviços
----------------

Para manter seu código organizado, você pode até criar seus próprios serviços! Suponha que você
queira gerar uma saudação aleatória (por exemplo, "Olá", "E aí", etc.). Em vez de colocar
esse código diretamente no seu controller, crie uma nova classe::

    // src/GreetingGenerator.php
    namespace App;

    class GreetingGenerator
    {
        public function getRandomGreeting()
        {
            $greetings = ['Ei', 'E aí', 'Aloha'];
            $greeting = $greetings[array_rand($greetings)];

            return $greeting;
        }
    }

Ótimo! Você pode usar isso imediatamente no seu controller::

    use App\GreetingGenerator;
    // ...

    public function index($name, LoggerInterface $logger, GreetingGenerator $generator)
    {
        $greeting = $generator->getRandomGreeting();

        $logger->info("Dizendo $greeting para $name!");

        // ...
    }

É isso aí! O Symfony irá instanciar o ``GreetingGenerator`` automaticamente e
irá passá-lo como um argumento. Mas, poderíamos *também* mover a lógica do logger para o ``GreetingGenerator``?
Sim! Você pode usar o autowiring dentro de um serviço para acessar *outros* serviços. A única
diferença é que isso é feito no construtor:

.. code-block:: diff

    + use Psr\Log\LoggerInterface;

    class GreetingGenerator
    {
    +     private $logger;
    +
    +     public function __construct(LoggerInterface $logger)
    +     {
    +         $this->logger = $logger;
    +     }

        public function getRandomGreeting()
        {
            // ...

     +        $this->logger->info('Usando a saudação: '.$greeting);

             return $greeting;
        }
    }

Sim! Isso funciona também: sem configuração, sem perda de tempo. Continue programando!

Extensões do Twig e Autoconfiguração
------------------------------------

Graças ao tratamento de serviços do Symfony, você pode *estender* o Symfony de várias maneiras, como
criar um subscriber de evento ou um voter de segurança para regras de autorização
complexas. Vamos adicionar um novo filtro ao Twig chamado ``greet``. Como? Basta criar uma classe
que estende ``AbstractExtension``::

    // src/Twig/GreetExtension.php
    namespace App\Twig;

    use App\GreetingGenerator;
    use Twig\Extension\AbstractExtension;
    use Twig\TwigFilter;

    class GreetExtension extends AbstractExtension
    {
        private $greetingGenerator;

        public function __construct(GreetingGenerator $greetingGenerator)
        {
            $this->greetingGenerator = $greetingGenerator;
        }

        public function getFilters()
        {
            return [
                new TwigFilter('greet', [$this, 'greetUser']),
            ];
        }

        public function greetUser($name)
        {
            $greeting =  $this->greetingGenerator->getRandomGreeting();

            return "$greeting $name!";
        }
    }

Depois de criar apenas *um* arquivo, você pode usar isso imediatamente:

.. code-block:: twig

    {# Irá imprimir algo como "Ei Symfony!" #}
    <h1>{{ name|greet }}</h1>

Como isso funciona? O Symfony percebe que sua classe estende ``AbstractExtension``
e, portanto, *automaticamente* a registra como uma extensão do Twig. Isso é chamado de autoconfiguração,
e funciona para *muitas* coisas. Basta criar uma classe e estender uma classe base
(ou implementar uma interface). O Symfony cuida do resto.

Velocidade Extrema: O Container em Cache
----------------------------------------

Depois de ver com o quanto o Symfony lida automaticamente, você pode estar se perguntando: "Isso não
prejudica o desempenho?" Na verdade, não! O Symfony é extremamente rápido.

Como isso é possível? O sistema de serviços é gerenciado por um objeto muito importante chamado
"container". A maioria dos frameworks tem um container, mas o do Symfony é único porque
é *armazenado em cache*. Quando você carregou sua primeira página, todas as informações dos serviços foram
compiladas e salvas. Isso significa que os recursos de autowiring e autoconfiguração
não adicionam *nenhuma* sobrecarga! Isso também significa que você recebe *grandes* erros: o Symfony inspeciona e
valida *tudo* quando o container é construído.

Agora você pode estar se perguntando, o que acontece quando você atualiza um arquivo e o cache precisa
ser reconstruído? Eu gosto do seu pensamento! Ele é inteligente o suficiente para ser reconstruído no próximo carregamento
de página. Mas esse é realmente o tópico da próxima seção.

Desenvolvimento versus Produção: Ambientes
------------------------------------------

Um dos principais trabalhos de um framework é facilitar a depuração! E nossa aplicação está *repleta* de
ótimas ferramentas para isso: a barra de ferramentas de depuração web é exibida na parte inferior da página, os erros
são grandes, bonitos e explícitos, e qualquer cache de configuração é reconstruído automaticamente
sempre que necessário.

Mas e quando você implantar em produção? Precisaremos esconder essas ferramentas e
otimizar a velocidade!

Isso é resolvido pelo sistema de *ambiente* do Symfony e existem três: ``dev``, ``prod``
e ``test``. Baseado no ambiente, o Symfony carrega arquivos diferentes no diretório
``config/``:

.. code-block:: text

    config/
    ├─ services.yaml
    ├─ ...
    └─ packages/
        ├─ framework.yaml
        ├─ ...
        ├─ **dev/**
            ├─ monolog.yaml
            └─ ...
        ├─ **prod/**
            └─ monolog.yaml
        └─ **test/**
            ├─ framework.yaml
            └─ ...
    └─ routes/
        ├─ annotations.yaml
        └─ **dev/**
            ├─ twig.yaml
            └─ web_profiler.yaml

Essa é uma idéia *poderosa*: ao alterar uma configuração (o ambiente),
sua aplicação é transformada de uma experiência amigável a depuração para uma que é otimizada
para velocidade.

E como você muda o ambiente? Altere a variável de ambiente ``APP_ENV``
de ``dev`` para ``prod``:

.. code-block:: diff

    # .env
    - APP_ENV=dev
    + APP_ENV=prod

Mas eu quero falar mais sobre as variáveis de ambiente a seguir. Altere o valor de volta
para ``dev``: as ferramentas de depuração são ótimas quando você está trabalhando localmente.

Variáveis de Ambiente
---------------------

Toda aplicação contém configurações diferentes em cada servidor - como informações
de conexão de banco de dados ou senhas. Como elas devem ser armazenadas? Em arquivos? Ou de alguma
outra forma?

O Symfony segue as práticas recomendadas da indústria, armazenando configurações baseadas em servidor
como variáveis de *ambiente*. Isso significa que o Symfony funciona *perfeitamente* com os
sistemas de implantação de Plataforma como Serviço (PaaS), assim como com o Docker.

Mas definir variáveis de ambiente durante o desenvolvimento pode ser doloroso. É por isso que sua
aplicação carrega automaticamente um arquivo ``.env``, se a variável de ambiente ``APP_ENV``
não estiver definida no ambiente. As chaves nesse arquivo se tornam variáveis de ambiente
e são lidas pela sua aplicação:

.. code-block:: bash

    # .env
    ###> symfony/framework-bundle ###
    APP_ENV=dev
    APP_SECRET=cc86c7ca937636d5ddf1b754beb22a10
    ###< symfony/framework-bundle ###

No começo, o arquivo não contém muito. Mas à medida que sua aplicação cresce, você adicionará mais
configurações conforme necessário. Mas, na verdade, fica muito mais interessante! Suponha que
sua aplicação precise de um ORM de banco de dados. Vamos instalar o Doctrine ORM:

.. code-block:: terminal

    $ composer require doctrine

Graças a uma nova receita instalada pelo Flex, veja o arquivo ``.env`` novamente:

.. code-block:: diff

    ###> symfony/framework-bundle ###
    APP_ENV=dev
    APP_SECRET=cc86c7ca937636d5ddf1b754beb22a10
    ###< symfony/framework-bundle ###

    + ###> doctrine/doctrine-bundle ###
    + # ...
    + DATABASE_URL=mysql://db_user:db_password@127.0.0.1:3306/db_name
    + ###< doctrine/doctrine-bundle ###

A nova variável de ambiente ``DATABASE_URL`` foi adicionada *automaticamente* e já é
referenciada pelo novo arquivo de configuração ``doctrine.yaml``. Combinando variáveis
de ambiente e o Flex, você está usando as práticas recomendadas da indústria sem nenhum esforço extra.

Continue!
---------

Me chame de louco, mas depois de ler esta parte, você deve estar confortável com as partes
mais *importantes* do Symfony. Tudo no Symfony foi projetado para sair do seu
caminho para que você possa continuar programando e adicionando recursos, tudo com a velocidade e qualidade que você
exige.

Isso é tudo para o guia rápido. De autenticação, a formulários, a armazenamento em cache, há
muito mais para descobrir. Pronto para entrar nestes tópicos agora? Não espere mais - vá
para a :doc:`/index` oficial e escolha qualquer guia que quiser.

.. _`Monolog`: https://github.com/Seldaek/monolog
