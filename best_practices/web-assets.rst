Web Assets
==========

Web assets são coisas como arquivos CSS, JavaScript e imagens que fazem com que o
frontend do seu site tenha uma ótima aparência e funcione muito bem.

.. best-practice::

    Armazene seus assets no diretório ``assets/`` na raiz do seu projeto.

A vida dos seus designers e desenvolvedores frontend será muito mais fácil se todos os
assets da aplicação estiverem centralizados em um único local.

.. best-practice::

    Use o `Webpack Encore`_ para compilar, combinar e minimizar os web assets.

O `Webpack`_ é o principal bundler de módulos JavaScript que compila, transforma
e empacota os assets para uso em um navegador. O Webpack Encore é uma biblioteca
JavaScript que se livra da maior parte da complexidade do Webpack sem esconder nenhum dos seus
recursos ou distorcer o seu uso e filosofia.

O Webpack Encore foi projetado para preencher a lacuna entre as aplicações Symfony e
as ferramentas baseadas em JavaScript usadas nas aplicações web modernas. Confira a
`documentação oficial do Webpack Encore`_ para saber mais sobre todos os recursos
disponíveis.

----

Próxima: :doc:`/best_practices/tests`

.. _`Webpack Encore`: https://github.com/symfony/webpack-encore
.. _`Webpack`: https://webpack.js.org/
.. _`documentação oficial do Webpack Encore`: https://symfony.com/doc/current/frontend.html
