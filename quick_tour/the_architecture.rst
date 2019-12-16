A Arquitetura
=============

Você é minha heroína! Quem diria que você ainda estaria aqui depois das duas
primeiras partes? Seus esforços serão bem recompensados em breve. Nas duas primeiras partes não analisamos
profundamente a arquitetura do framework. Já que ela faz o Symfony se destacar
na multidão de frameworks, vamos mergulhar na arquitetura agora.

Adicione Logging
----------------

Uma nova aplicação Symfony é micro: ela é basicamente apenas um sistema de roteamento e controllers. Mas,
graças ao Flex, a instalação de mais recursos é simples.

Quer um sistema de logging? Sem problema:

.. code-block:: terminal

    $ composer require logger

Isso instala e configura (através de uma receita) a poderosa biblioteca `Monolog`_. Para
usar o logger em um controller, adicione um novo argumento com a declaração de tipo ``LoggerInterface``::

    // src/Controller/DefaultController.php
    namespace App\Controller;

    use Psr\Log\LoggerInterface;
    use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
    use Symfony\Component\Routing\Annotation\Route;

    class DefaultController extends AbstractController
    {
        /**
         * @Route("/hello/{name}")
         */
        public function index($name, LoggerInterface $logger)
        {
            $logger->info("Dizendo olá para $name!");

            // ...
        }
    }

É isso aí! A nova mensagem de log será gravada em ``var/log/dev.log``. O caminho
do arquivo de log ou mesmo um método diferente de logging podem ser configurados atualizando
um dos arquivos de configuração adicionados pela receita.

Serviços e Autowiring
---------------------

Mas espere! Algo *muito* legal acabou de acontecer. O Symfony leu a declaração de tipo
``LoggerInterface`` e descobriu automaticamente que deveria nos passar o objeto Logger!
Isso é chamado de *autowiring*.

Todo trabalho realizado numa aplicação Symfony é feito por um *objeto*: o objeto
Logger registra coisas e o objeto Twig renderiza templates. Estes objetos são chamados
*serviços* e são *ferramentas* que te ajudam a construir recursos avançados.

Para tornar a vida incrível, você pode pedir ao Symfony para te fornecer um serviço usando uma declaração de tipo.
Quais outras possíveis classes ou interfaces você poderia usar? Descubra executando:

.. code-block:: terminal

    $ php bin/console debug:autowiring

      # esta é apenas uma *pequena* amostra da saída...

      Describes a logger instance.
      Psr\Log\LoggerInterface (monolog.logger)

      Request stack that controls the lifecycle of requests.
      Symfony\Component\HttpFoundation\RequestStack (request_stack)

      Interface for the session.
      Symfony\Component\HttpFoundation\Session\SessionInterface (session)

      RouterInterface is the interface that all Router classes must implement.
      Symfony\Component\Routing\RouterInterface (router.default)

      [...]

Este é apenas um breve resumo da lista completa! E à medida que você adiciona mais pacotes esta
lista de ferramentas aumenta!

Criando Serviços
----------------

Para manter seu código organizado você pode até mesmo criar seus próprios serviços! Suponha que você
queira gerar uma saudação aleatória (por exemplo, "Olá", "Yo", etc). Em vez de colocar
esse código diretamente no seu controller, crie uma nova classe::

    // src/GreetingGenerator.php
    namespace App;

    class GreetingGenerator
    {
        public function getRandomGreeting()
        {
            $greetings = ['Ei', 'Yo', 'Aloha'];
            $greeting = $greetings[array_rand($greetings)];

            return $greeting;
        }
    }

Ótimo! Você pode usar ela imediatamente no seu controller::

    // src/Controller/DefaultController.php
    namespace App\Controller;

    use App\GreetingGenerator;
    use Psr\Log\LoggerInterface;
    use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
    use Symfony\Component\Routing\Annotation\Route;

    class DefaultController extends AbstractController
    {
        /**
         * @Route("/hello/{name}")
         */
        public function index($name, LoggerInterface $logger, GreetingGenerator $generator)
        {
            $greeting = $generator->getRandomGreeting();

            $logger->info("Dizendo $greeting para $name!");

            // ...
        }
    }

É isso aí! O Symfony instancia o ``GreetingGenerator`` automaticamente e
o passa como um argumento. Mas, *também* poderíamos mover a lógica do logger para ``GreetingGenerator``?
Sim! Você pode usar o autowiring dentro de um serviço para acessar *outros* serviços. A única
diferença é que isso é feito no construtor:

.. code-block:: diff

    // src/GreetingGenerator.php
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

Isso! Assim também funciona: sem configuração, sem perda de tempo. Continue codando!

Extensão do Twig e Configuração Automática
------------------------------------------

Graças ao gerenciamento de serviços do Symfony, você pode *extender* o Symfony de várias maneiras, por exemplo,
criando um subscriber de evento ou um voter de segurança para regras complexas de
autorização. Vamos adicionar um novo filtro ao Twig chamado ``greet``. Como? Crie uma classe
que extende ``AbstractExtension``::

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

            return "$greeting, $name!";
        }
    }

Após criar apenas *um* arquivo, você pode usá-lo imediatamente:

.. code-block:: html+twig

    {# templates/default/index.html.twig #}
    {# Irá imprimir algo como "Ei, Symfony!" #}
    <h1>{{ name|greet }}</h1>

Como isso funciona? O Symfony nota que sua classe extende ``AbstractExtension``
e então *automaticamente* a registra como uma extensão do Twig. Isso é chamado de configuração automática
e funciona para *muitas* coisas. Crie uma classe e depois extenda uma classe base
(ou implemente uma interface). O Symfony cuida do resto.

Super Velocidade: O Container Armazenado em Cache
-------------------------------------------------

Depois de ver quanta coisa o Symfony gerencia automaticamente, você pode estar se perguntando: "Isso não
prejudica o desempenho?" Na verdade, não! O Symfony é super rápido.

Como isso é possível? O sistema de serviços é gerenciado por um objeto muito importante chamado
"container". A maioria dos frameworks tem um container, mas o do Symfony é único porque
ele é *armazenado em cache*. Quando você carregou sua primeira página, todas as informações de serviço foram
compiladas e salvas. Isso significa que os recursos de autowiring e configuração automática
*não* adicionam nenhuma sobrecarga! Isso também significa que você obtém *grandes* erros: o Symfony inspeciona e
valida *tudo* quando o container é construído.

Agora você deve estar se perguntando o que acontece quando você atualiza um arquivo e o cache precisa
ser reconstruído? Eu gosto da sua forma de pensar! O cache é inteligente o suficiente para se reconstruir no próximo carregamento
de página. Mas esse é realmente o tópico da próxima seção.

Desenvolvimento versus Produção: Ambientes
------------------------------------------

Um dos principais trabalhos de um framework é facilitar a depuração! E nossa aplicação está *cheia* de
ótimas ferramentas para isso: a barra de ferramentas de depuração web é exibida na parte inferior da página, os erros
são grandes, bonitos e explícitos, e qualquer cache de configuração é reconstruído automaticamente
sempre que necessário.

Mas e quando você implanta em produção? Precisamos esconder estas ferramentas e
otimizar a velocidade!

Isso é resolvido pelo sistema de *ambiente* do Symfony e existem três: ``dev``, ``prod``
e ``test``. Com base no ambiente o Symfony carrega arquivos diferentes no diretório
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

Essa é uma idéia *poderosa*: ao alterar uma parte da configuração (o ambiente),
sua aplicação é transformada de uma experiência amigável à depuração para uma otimizada
para velocidade.

Ah, como você altera o ambiente? Altere a variável de ambiente ``APP_ENV``
de ``dev`` para ``prod``:

.. code-block:: diff

    # .env
    - APP_ENV=dev
    + APP_ENV=prod

Mas quero falar mais sobre variáveis de ambiente a seguir. Altere o valor de volta
para ``dev``: ferramentas de depuração são ótimas quando você está trabalhando localmente.

Variáveis de Ambiente
---------------------

Toda aplicação contém configuração que é diferente em cada servidor - como informação
de conexão com o banco de dados ou senhas. Como elas devem ser armazenadas? Em arquivos? Ou de alguma
outra forma?

O Symfony segue as melhores práticas da indústria armazenando as configurações baseadas em servidor
como variáveis de *ambiente*. Isso significa que o Symfony funciona *perfeitamente* com
os sistemas de implantação de Plataformas como Serviço (PaaS) e com o Docker.

Mas definir variáveis de ambiente durante o desenvolvimento pode ser doloroso. É por isso que sua
aplicação carrega automaticamente um arquivo ``.env``. As chaves neste arquivo se tornam variáveis
de ambiente e são lidas pela sua aplicação:

.. code-block:: bash

    # .env
    ###> symfony/framework-bundle ###
    APP_ENV=dev
    APP_SECRET=cc86c7ca937636d5ddf1b754beb22a10
    ###< symfony/framework-bundle ###

A princípio, o arquivo não contém muita coisa. Mas à medida que sua aplicação cresce, você adicionará mais
configurações conforme necessário. Mas, na verdade, isso fica muito mais interessante! Suponha que
sua aplicação precisa de um ORM de banco de dados. Vamos instalar o Doctrine ORM:

.. code-block:: terminal

    $ composer require doctrine

Graças a uma nova receita instalada pelo Flex, olhe o arquivo ``.env`` novamente:

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
referenciada pelo novo arquivo de configuração ``doctrine.yaml``. Ao combinar variáveis
de ambiente e o Flex, você está usando as melhores práticas da indústria sem nenhum esforço extra.

Continue!
---------

Pode me chamar de louco, mas depois de ler esta parte, você deve se sentir confortável com as partes
mais *importantes* do Symfony. Tudo no Symfony foi projetado para te ajudar ao máximo
para que você possa continuar codando e adicionando recursos, tudo com a velocidade e a qualidade que você
exige.

Isso é tudo para o tour rápido. Da autenticação aos formulários e ao cache, ainda há
muito mais a descobrir. Pronta para mergulhar nestes tópicos agora? Não procure mais - vá
para a :doc:`/index` e escolha o guia que desejar.

.. _`Monolog`: https://github.com/Seldaek/monolog
