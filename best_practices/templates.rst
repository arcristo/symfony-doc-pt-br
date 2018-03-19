plates
=========

Quando o PHP foi criado, há 20 anos atrás, os desenvolvedores amaram sua simplicidade e o quão
bem ele combinava HTML e código dinâmico. Mas com o passar do tempo, outras linguagens
de template - como o `Twig`_ - foram criadas para tornar os templates ainda melhores.

.. best-practice::

    Use o formato de templates Twig para seus templates.

De modo geral, os templates PHP são mais verbosos do que os templates Twig porque
eles não possuem suporte nativo a muitos recursos modernos necessários aos templates,
como herança, escaping automático e argumentos nomeados para filtros e
funções.

O Twig é o formato de template padrão no Symfony e possui o maior suporte da
comunidade entre todas as engines de template não-PHP (ele é usado em projetos de grande destaque
como o Drupal 8).

Localização dos Templates
-------------------------

.. best-practice::

    Armazene os templates da sua aplicação no diretório ``templates/`` na raiz
    do seu projeto.

Centralizar seus templates em um único local simplifica o trabalho dos seus
designers. Além disso, o uso deste diretório simplifica a notação usada ao
se referir aos templates (por exemplo, ``$this->render('admin/post/show.html.twig')``
ao invés de ``$this->render('@SomeTwigNamespace/Admin/Posts/show.html.twig')``).

.. best-practice::

    Use o formato snake_case em minúsculas para nomes de diretórios e templates.

Esta recomendação alinha-se às práticas recomendadas do Twig, onde os nomes de variáveis e
templates também usam o formato snake_case em minúsculas (por exemplo, ``user_profile`` ao invés de ``userProfile``
e ``edit_form.html.twig`` ao invés de ``EditForm.html.twig``).

.. best-practice::

    Use um underscore como prefixo para nomes de templates parciais.

Muitas vezes você deseja reutilizar o código de templates usando a função ``include`` para evitar
código redundante. Para identificar facilmente esses templates parciais no sistema de arquivos você deve
prefixar os templates parciais e qualquer outro template sem a tag HTML body ou a tag ``extends``
com um único underscore.

Extensões Twig
--------------

.. best-practice::

    Defina suas extensões Twig no diretório ``src/Twig/``. Sua
    aplicação irá automaticamente detectá-las e configurá-las.

Nossa aplicação precisa de um filtro Twig ``md2html`` personalizado para que possamos transformar
o conteúdo Markdown de cada post em HTML. Para fazer isso, crie uma nova classe
``Markdown`` que será usada mais tarde pela extensão Twig. Ela só precisa
definir um único método para transformar o conteúdo Markdown em HTML::

    namespace App\Utils;

    class Markdown
    {
        // ...

        public function toHtml(string $text): string
        {
            return $this->parser->text($text);
        }
    }

Em seguida, crie uma nova extensão Twig e defina um filtro chamado ``md2html`` usando
a classe ``TwigFilter``. Injete a classe ``Markdown`` recém-definida no
construtor da extensão Twig:

.. code-block:: php

    namespace App\Twig;

    use App\Utils\Markdown;
    use Twig\Extension\AbstractExtension;
    use Twig\TwigFilter;

    class AppExtension extends AbstractExtension
    {
        private $parser;

        public function __construct(Markdown $parser)
        {
            $this->parser = $parser;
        }

        public function getFilters()
        {
            return [
                new TwigFilter('md2html', [$this, 'markdownToHtml'], [
                    'is_safe' => ['html'],
                    'pre_escape' => 'html',
                ]),
            ];
        }

        public function markdownToHtml($content)
        {
            return $this->parser->toHtml($content);
        }
    }

E é isso!

Se você estiver usando a :ref:`configuração padrão do services.yaml <service-container-services-load-example>`,
você terminou! O Symfony saberá automaticamente sobre o seu novo serviço e irá marcá-lo para
ser usado como uma extensão Twig.

----

Próxima: :doc:`/best_practices/forms`

.. _`Twig`: http://twig.sensiolabs.org/
.. _`Parsedown`: http://parsedown.org/
