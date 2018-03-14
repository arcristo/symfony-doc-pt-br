Criando o Projeto
=================

Instalando o Symfony
--------------------

.. best-practice::

    Use o Composer e o Symfony Flex para criar e gerenciar aplicações Symfony.

`Composer`_ é o gerenciador de pacotes usado por aplicações PHP modernas para gerenciar
suas dependências. O `Symfony Flex`_ é um plugin do Composer projetado para automatizar
algumas das tarefas mais comuns executadas em aplicações Symfony. O uso do Flex é
opcional mas recomendado porque melhora significativamente sua produtividade.

.. best-practice::

    Use o Esqueleto do Symfony para criar novos projetos baseados em Symfony.

O `Esqueleto do Symfony`_ é um projeto Symfony mínimo e vazio no qual você pode
basear seus novos projetos. Ao contrário das versões anteriores do Symfony, este esqueleto instala
a quantidade mínima absoluta de dependências para criar um projeto Symfony totalmente
funcional. Leia o artigo :doc:`/setup` para saber mais sobre a instalação do Symfony.

.. _linux-and-mac-os-x-systems:
.. _windows-systems:

Criando a Aplicação do Blog
---------------------------

No seu console de comando, navegue até um diretório onde você tem permissão para
criar arquivos e execute os seguintes comandos:

.. code-block:: terminal

    $ cd projects/
    $ composer create-project symfony/skeleton blog

Este comando cria um novo diretório chamado ``blog`` que contém um novo
projeto baseado na versão estável mais recente do Symfony disponível.

.. tip::

    Os requisitos técnicos para rodar o Symfony são simples. Se você quiser verificar
    se o seu sistema atende a esses requisitos, leia :doc:`/reference/requirements`.

Estruturando a Aplicação
------------------------

Depois de criar a aplicação, entre no diretório ``blog/`` e você verá uma
série de arquivos e diretórios gerados automaticamente:

.. code-block:: text

    blog/
    ├─ bin/
    │  └─ console
    ├─ config/
    └─ public/
    │  └─ index.php
    ├─ src/
    │  └─ Kernel.php
    ├─ var/
    │  ├─ cache/
    │  └─ log/
    └─ vendor/

Esta hierarquia de arquivos e diretórios é a convenção proposta pelo Symfony para
estruturar suas aplicações. Recomenda-se manter esta estrutura porque é
fácil de navegar e a maioria dos nomes dos diretórios são auto-explicativos, mas você pode
:doc:`sobrescrever a localização de qualquer diretório do Symfony </configuration/override_dir_structure>`.

Bundles da Aplicação
~~~~~~~~~~~~~~~~~~~~

Quando o Symfony 2.0 foi lançado, a maioria dos desenvolvedores naturalmente adotou a forma
de dividir as aplicações em módulos lógicos do Symfony 1.x. É por isso que muitas apps Symfony
usam bundles para dividir seu código em recursos lógicos: UserBundle,
ProductBundle, InvoiceBundle, etc.

Mas um bundle *deve* ser algo que pode ser reutilizado como um software
autônomo. Se o UserBundle não pode ser usado *"como está"* em outras apps
Symfony, então não deve ser seu próprio bundle. Além disso, se o InvoiceBundle depende
do ProductBundle, então não há nenhuma vantagem em ter dois bundles separados.

.. best-practice::

    Não crie nenhum bundle para organizar a lógica da sua aplicação.

As aplicações Symfony ainda podem usar bundles de terceiros (instalados em ``vendor/``)
para adicionar recursos, mas você deve usar namespaces do PHP ao invés de bundles para organizar
seu próprio código.

----

Próxima: :doc:`/best_practices/configuration`

.. _`Composer`: https://getcomposer.org/
.. _`Symfony Flex`: https://github.com/symfony/flex
.. _`Esqueleto do Symfony`: https://github.com/symfony/skeleton
