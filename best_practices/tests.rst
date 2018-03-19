Testes
======

De todos os diferentes tipos de testes disponíveis, essas melhores práticas focam exclusicamente
em testes unitários e funcionais. Os testes unitários permitem testar a entrada e
saída de funções específicas. Os testes funcionais permitem comandar um
"navegador", onde é possível navegar pelas páginas do seu site, clicar em links, preencher formulários
e comprovar que existem certas coisas na página.

Testes Unitários
----------------

Os testes unitários são usados para testar a sua "lógica de negócio", que deve residir em classes
que são independentes do Symfony. Por essa razão, o Symfony não tem
realmente uma opinião sobre quais ferramentas você usa para os testes unitários. No entanto, as
ferramentas mais populares são `PhpUnit`_ e `PhpSpec`_.

Testes Funcionais
-----------------

Criar testes funcionais realmente bons pode ser difícil, então alguns desenvolvedores ignoram
estes completamente. Não ignore os testes funcionais! Ao definir alguns testes
funcionais *simples*, você pode detectar rapidamente quaisquer grandes erros antes de implantá-los:

.. best-practice::

    Defina um teste funcional que, pelo menos, verifique se as páginas da sua aplicação
    estão sendo carregadas com sucesso.

Um teste funcional pode ser tão fácil quanto isso::

    // tests/ApplicationAvailabilityFunctionalTest.php
    namespace App\Tests;

    use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

    class ApplicationAvailabilityFunctionalTest extends WebTestCase
    {
        /**
         * @dataProvider urlProvider
         */
        public function testPageIsSuccessful($url)
        {
            $client = self::createClient();
            $client->request('GET', $url);

            $this->assertTrue($client->getResponse()->isSuccessful());
        }

        public function urlProvider()
        {
            yield ['/'];
            yield ['/posts'];
            yield ['/post/fixture-post-1'];
            yield ['/blog/category/fixture-category'];
            yield ['/archives'];
            // ...
        }
    }

Este código verifica se todos os URLs fornecidos são carregados com sucesso, o que significa que
o código de status das respostas HTTP está entre ``200`` e ``299``. Isso pode
não parecer tão útil, mas levando em consideração o pouco esforço necessário, vale a pena
ter em sua aplicação.

Em software de computador, esse tipo de teste é chamado `teste de fumaça`_ e consiste
em *"testes preliminares para revelar falhas simples graves o suficiente para rejeitar um
potencial lançamento de software"*.

Codifique os URLs em um Teste Funcional
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Alguns de vocês podem estar se perguntando por que o teste funcional anterior não usa o serviço
gerador de URL:

.. best-practice::

    Codifique os URLs usados nos testes funcionais em vez de usar o gerador
    de URL.

Considere o seguinte teste funcional que usa o serviço ``router`` para
gerar o URL da página testada::

    // ...
    private $router; // considere que isso contém o serviço router do Symfony

    public function testBlogArchives()
    {
        $client = self::createClient();
        $url = $this->router->generate('blog_archives');
        $client->request('GET', $url);

        // ...
    }

Isso irá funcionar, mas tem uma *enorme* desvantagem. Se um desenvolvedor alterar
por engano o caminho da rota ``blog_archives``, o teste ainda passará,
mas o URL original (antigo) não funcionará! Isso significa que quaisquer links salvos para
aquele URL estarão quebrados e você perderá qualquer classificação da página nas engines de busca.

Testando a Funcionalidade do JavaScript
---------------------------------------

O cliente de teste funcional embutido é ótimo, mas não pode ser usado para
testar qualquer comportamento do JavaScript em suas páginas. Se você precisa testar isso, considere
usar a biblioteca `Mink`_ dentro do PHPUnit.

Claro, se você tem um frontend JavaScript pesado, deve considerar o uso
de ferramentas de teste em JavaScript puro.

Saiba Mais sobre Testes Funcionais
----------------------------------

Considere usar o `HautelookAliceBundle`_ para gerar dados parecidos com os reais para
os seus fixtures de teste usando `Faker`_ e `Alice`_.

.. _`PhpUnit`: https://phpunit.de/
.. _`PhpSpec`: http://www.phpspec.net/
.. _`teste de fumaça`: https://en.wikipedia.org/wiki/Smoke_testing_(software)
.. _`Mink`: http://mink.behat.org
.. _`HautelookAliceBundle`: https://github.com/hautelook/AliceBundle
.. _`Faker`: https://github.com/fzaninotto/Faker
.. _`Alice`: https://github.com/nelmio/alice
