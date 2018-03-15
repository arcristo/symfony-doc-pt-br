.. index::
   single: Melhores Práticas do Framework Symfony

As Melhores Práticas do Framework Symfony
=========================================

O Framework Symfony é bem conhecido por ser *realmente* flexível e é usado
para construir micro-sites, aplicações corporativas que lidam com bilhões de conexões
e até mesmo como base para *outros* frameworks. Desde o seu lançamento, em julho de 2011,
a comunidade tem aprendido muito sobre o que é possível e como tornar as coisas *melhores*.

Esses recursos da comunidade - como postagens de blogs ou apresentações - criaram
um conjunto não-oficial de recomendações para o desenvolvimento de aplicações Symfony.
Infelizmente, muitas dessas recomendações são desnecessárias para aplicações web.
Na maioria das vezes, elas complicam desnecessariamente as coisas e não seguem a
filosofia pragmática original do Symfony.

Sobre o que é este Guia?
------------------------

Este guia visa corrigir isso, descrevendo as **melhores práticas para desenvolver
aplicações web com o framework fullstack Symfony**. Estas são práticas recomendadas que
se encaixam na filosofia do framework como imaginada pelo seu criador original
`Fabien Potencier`_.

.. note::

    **Melhor prática** é um substantivo que significa *"um procedimento bem definido que é
    conhecido por produzir resultados quase ótimos"*. E é exatamente isso que este
    guia pretende fornecer. Mesmo que você não concorde com todas as recomendações,
    acreditamos que elas irão ajudá-lo a construir ótimas aplicações com menos complexidade.

Este guia é **especialmente adequado** para:

* Sites e aplicações web desenvolvidos com o framework fullstack Symfony.

Para outras situações, este guia pode ser um bom **ponto de partida** que você pode
então **ampliar e ajustar às suas necessidades específicas**:

* Bundles compartilhados publicamente com a comunidade Symfony;
* Desenvolvedores avançados ou equipes que criaram seus próprios padrões;
* Algumas aplicações complexas que têm requisitos altamente personalizados;
* Bundles que podem ser compartilhados internamente dentro de uma empresa.

Sabemos que velhos hábitos custam a ser eliminados e alguns de vocês ficarão chocados com algumas
dessas melhores práticas. Mas, seguindo elas, você poderá desenvolver
aplicações mais rapidamente, com menos complexidade e com a mesma ou até superior qualidade.
É também um alvo em movimento que continuará a melhorar.

Tenha em mente que estas são **recomendações opcionais** que você e sua
equipe podem ou não seguir para desenvolver aplicações Symfony. Se você quiser
continuar usando suas próprias práticas recomendadas e metodologias, você pode, claro,
fazê-lo. O Symfony é flexível o suficiente para se adaptar às suas necessidades. Isso nunca
mudará.

Para quem é este Livro (Dica: Não é um Tutorial)
------------------------------------------------

Qualquer desenvolvedor Symfony, seja um especialista ou um recém-chegado, pode ler este
guia. Mas como este não é um tutorial, você precisará de algum conhecimento básico do
Symfony para acompanhar tudo. Se você é completamente novo no Symfony, bem-vindo! E
leia os :doc:`Guias de Início Rápido </quick_tour/the_big_picture>` primeiro.

Nós deliberadamente mantivemos este guia curto. Não vamos repetir explicações que
você pode encontrar na vasta documentação do Symfony, como discussões sobre Injeção de
Dependência ou front controllers. Vamos apenas nos concentrar em explicar como fazer
o que você já sabe.

A Aplicação
-----------

Além deste guia, um exemplo de aplicação chamada `Demo do Symfony`_ foi
desenvolvido com todas essas práticas recomendadas em mente. Execute este comando para baixar
a aplicação de demonstração:

.. code-block:: terminal

    $ composer create-project symfony/symfony-demo

**A aplicação de demonstração é uma engine de blog simples**, porque isso nos permitirá
focar nos conceitos e características do Symfony sem ficar enterrados em detalhes de
implementação difíceis. Em vez de desenvolver a aplicação passo-a-passo
neste guia, você encontrará fragmentos de código selecionados através dos capítulos.

Não Atualize suas Aplicações Existentes
---------------------------------------

Depois de ler este manual, alguns de vocês podem estar pensando em refatorar suas
aplicações Symfony existentes. Nossa recomendação é sólida e clara: você pode
usar estas práticas recomendadas para **novas aplicações**, mas **você não deve refatorar
suas aplicações existentes para cumprir essas práticas recomendadas**. As razões
para não fazê-lo são várias:

* Suas aplicações existentes não estão erradas, elas apenas seguem um outro conjunto de
  diretrizes;
* Uma refatoração completa da base de código está propensa a introduzir erros em suas
  aplicações;
* A quantidade de trabalho gasto com isso poderia ser melhor dedicada a melhorar
  seus testes ou adicionar funcionalidades que agreguem valor real para os usuários finais.

----

Próxima: :doc:`/best_practices/creating-the-project`

.. _`Fabien Potencier`: https://connect.sensiolabs.com/profile/fabpot
.. _`Demo do Symfony`: https://github.com/symfony/demo
