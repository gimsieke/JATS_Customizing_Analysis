<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xhtml="http://www.w3.org/1999/xhtml" 
  xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  exclude-result-prefixes="#all">

  <xsl:output indent="yes" method="xml"/>

  <xsl:param name="base-dir-uri" as="xs:string?"/>

  <xsl:param name="html-docs" as="document-node()*"
    select="collection($base-dir-uri || '?recurse=yes;select=*.xhtml')"/>

  <xsl:template name="main">
    <xsl:variable name="element-lists" as="element(xhtml:ul)*" select="$html-docs/xhtml:html/xhtml:body/xhtml:ul[1]"/>
    <xsl:message select="'Counts: ', $element-lists ! count(xhtml:li)"/>
    <xsl:variable name="customizations" as="document-node(element(customizations))">
      <xsl:document>
        <customizations>
          <xsl:for-each select="$element-lists">
            <xsl:variable name="outer-element-list" as="element(xhtml:ul)" select="."/>
            <xsl:variable name="outer-attribute-list" as="element(xhtml:ul)" select="$outer-element-list/following-sibling::xhtml:ul[1]"/>
            <customization 
              name="{(
                       root($outer-element-list)/xhtml:html/xhtml:head/xhtml:meta[@name='customization-name']/@content,
                       xhtml:notdir(root($outer-element-list)/xhtml:html/xhtml:head/xhtml:meta[@name='storage-location']/@content)
                     )[1]}" 
              items="{count(xhtml:li) + count($outer-attribute-list/xhtml:li)}">
              <xsl:copy-of select="ancestor::xhtml:body/@class"/>
              <xsl:for-each select="$element-lists except $outer-element-list">
                <xsl:variable name="inner-element-list" as="element(xhtml:ul)" select="."/>
                <xsl:variable name="inner-attribute-list" as="element(xhtml:ul)" select="$inner-element-list/following-sibling::xhtml:ul[1]"/>
                <xsl:variable name="not-in" as="element(xhtml:li)*" 
                  select="$outer-element-list/xhtml:li[not(. = $inner-element-list/xhtml:li)]
                          union
                          $outer-attribute-list/xhtml:li[not(. = $inner-attribute-list/xhtml:li)]"/>
                <items not-in="{(
                                  root($inner-element-list)/xhtml:html/xhtml:head/xhtml:meta[@name='customization-name']/@content,
                                  xhtml:notdir(root($inner-element-list)/xhtml:html/xhtml:head/xhtml:meta[@name='storage-location']/@content)
                                )[1]}"
                  count="{count($not-in)}">
                  <xsl:value-of select="$not-in"/>
                </items>
              </xsl:for-each>
            </customization>
          </xsl:for-each>
        </customizations>
      </xsl:document>
    </xsl:variable>
    
    <xsl:result-document href="{$base-dir-uri}/debug/0_customizations.xml">
      <xsl:sequence select="$customizations"/>
    </xsl:result-document>
    <xsl:variable name="computed-s-q" as="document-node(element(customizations))">
      <xsl:apply-templates select="$customizations" mode="compute"/>
    </xsl:variable>
    <xsl:result-document href="{$base-dir-uri}/debug/1_computed-s-q.xml">
      <xsl:sequence select="$computed-s-q"/>
    </xsl:result-document>
    <xsl:variable name="minmax" as="document-node(element(customizations))">
      <xsl:apply-templates select="$computed-s-q" mode="minmax"/>
    </xsl:variable>
    <xsl:result-document href="{$base-dir-uri}/debug/2_minmax.xml">
      <xsl:sequence select="$minmax"/>
    </xsl:result-document>
    <xsl:variable name="best-fit" as="document-node(element(customizations))">
      <xsl:apply-templates select="$minmax" mode="best-fit"/>
    </xsl:variable>
    <xsl:result-document href="{$base-dir-uri}/debug/3_best-fit.xml">
      <xsl:sequence select="$best-fit"/>
    </xsl:result-document>
    <xsl:variable name="html-table" as="document-node(element(xhtml:html))">
      <xsl:apply-templates select="$best-fit" mode="html-table"/>
    </xsl:variable>
<!--    <xsl:result-document href="{$base-dir-uri}/customizations.xhtml" method="xhtml">-->
      <xsl:sequence select="$html-table"/>
    <!--</xsl:result-document>-->
  </xsl:template>

  <xsl:mode name="compute" on-no-match="shallow-copy"/>

  <xsl:mode name="minmax" on-no-match="shallow-copy"/>
  
  <xsl:mode name="best-fit" on-no-match="shallow-copy"/>

  <xsl:key name="ij" match="customization/*[@not-in]" use="string-join((@not-in, ../@name), ',')"/>

  <xsl:template match="customization/*[@not-in]" mode="compute">
    <xsl:variable name="a_ij" as="xs:integer" select="@count">
      <!-- Elements of the current customization that are not in the customization referenced by @not-in.
      If this is 0, then the @not-in customization is a superset of the current. -->
    </xsl:variable>
    <xsl:message select="'JJJJJJJJJJJJJ ', string-join((../@name, @not-in), ',')"/>
    <xsl:variable name="ji" as="element(*)*" select="key('ij', string-join((../@name, @not-in), ','))"/>
    <xsl:if test="count($ji) gt 1">
      <xsl:message select="'IIIIIIIIIIIII ', ../.."></xsl:message>
    </xsl:if>
    <xsl:variable name="a_ji" as="xs:integer" select="$ji/@count"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:variable name="distance" select="$a_ij + $a_ji" as="xs:integer"/>
      <xsl:attribute name="distance" select="$distance"/>
      <xsl:if test="$distance gt 0">
        <xsl:variable name="r_ij" as="xs:double" select="$a_ij"/>
        <xsl:variable name="r_ji" as="xs:double" select="$a_ji div $distance"/>
        <xsl:variable name="supersetticity1" select="$a_ji - $a_ij" as="xs:integer"/>
        <xsl:variable name="supersetticity2" select="$a_ji div (1 + $a_ij)" as="xs:double"/>
        <xsl:variable name="supersetticity4" select="(1 + $a_ji) div (1 + $a_ij)" as="xs:double"/>
        <xsl:variable name="supersetticity5" select="(1 + $r_ji) div (1 + $r_ij)" as="xs:double"/>
        <xsl:variable name="q1" as="xs:double" select="$supersetticity1 div $distance"/>
        <xsl:variable name="q2" as="xs:double" select="$supersetticity2 div $distance"/>
        <xsl:variable name="q3" as="xs:double" select="$supersetticity1 div ($distance * $distance)"/>
        <xsl:variable name="q4" as="xs:double" select="($supersetticity4 div $distance) * 100"/>
        <xsl:variable name="q5" as="xs:double" select="($supersetticity5 div $distance) * 100"/>
        <xsl:attribute name="s1" select="$supersetticity1"/>
        <xsl:attribute name="s2" select="format-number($supersetticity2, '.##')"/>
        <xsl:attribute name="s4" select="format-number($supersetticity4, '.##')"/>
        <xsl:attribute name="s5" select="format-number($supersetticity5, '.####')"/>
        <xsl:attribute name="q1" select="format-number($q1, '.##')"/>
        <xsl:attribute name="q2" select="format-number($q2, '.##')"/>
        <xsl:attribute name="q3" select="format-number($q3, '.##')"/>
        <xsl:attribute name="q4" select="format-number($q4, '.##')"/>
        <xsl:attribute name="q5" select="format-number($q5, '.####')"/>
        <xsl:comment>
s: “supersetticity” of <xsl:value-of select="@not-in"/> with respect to <xsl:value-of select="../@name"/>
q: degree to which <xsl:value-of select="@not-in"/> is suitable to derive <xsl:value-of select="../@name"/> from
        </xsl:comment>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="customization/@name" mode="minmax">
    <xsl:param name="max_q5" as="xs:double" tunnel="yes"/>
    <xsl:next-match/>
    <xsl:attribute name="max_q5" select="$max_q5"/>
  </xsl:template>
  
  <xsl:template match="customization" mode="minmax">
    <xsl:next-match>
      <xsl:with-param name="max_q5" as="xs:double" select="max(items/@q5)" tunnel="yes"/>
    </xsl:next-match>
  </xsl:template>
  
  <xsl:template match="items/@q5" mode="minmax">
    <xsl:param name="max_q5" as="xs:double" tunnel="yes"/>
    <xsl:next-match/>
    <xsl:attribute name="p5" select="format-number(. div $max_q5 * 100, '.##')"/>
  </xsl:template>
  
  <xsl:template match="customization/@name" mode="best-fit">
    <xsl:next-match/>
    <xsl:variable name="p5s" as="attribute(p5)*" select="//items[@not-in = current()]/@p5"/>
    <xsl:attribute name="average_p5" select="format-number(sum($p5s) div count($p5s), '.##')"/>
    <xsl:variable name="s5s" as="attribute(s5)*" select="//items[@not-in = current()]/@s5"/>
    <xsl:attribute name="average_s5" select="format-number(sum($s5s) div count($s5s), '.##')"/>
    <xsl:variable name="collection-s5s" as="attribute(s5)*" 
      select="/customizations/customization[not(@class = 'schema')]/items[@not-in = current()]/@s5"/>
    <xsl:attribute name="average_collection-s5" select="format-number(sum($collection-s5s) div count($collection-s5s), '.##')"/>
  </xsl:template>
  

  <xsl:function name="xhtml:notdir" as="xs:string">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:sequence select="tokenize($uri, '/')[last()] => replace('_expanded', '') => replace('\.xhtml', '')"/>
  </xsl:function>

  <xsl:template match="/customizations" mode="html-table">
      <xsl:document>
        <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
          <title>RNG List</title>
          <meta charset="utf-8"/>
          <style>
tr > th {
  width: 20em;
  height: 2em;
}
tr.colheads > th { 
  transform: rotate(-90deg);
<!--  transform-origin: 7em 10em;-->
  transform-origin: 6em 12em;
  width:6em;
  height:20em;
}
tr.colheads > th.origin {
  transform: none;
}
td {
  width:6em;
  height:2em;
}
table {
  border-collapse:collapse;
  table-layout:fixed;
  width:100%;
}
td, th {
  border: 1px solid black;
}
.max {
  background-color: #9f9;
}
.average {
  text-decoration: overline;
}
tr.summary > * {
  border-top: 3px solid black;
}
          </style>
        </head>
        <body>
          <xsl:variable name="context" as="element(customizations)" select="."/>
          <xsl:variable name="all-customizings" as="xs:string+">
            <xsl:perform-sort select="customization/@name">
              <xsl:sort select="../@class" order="descending"/>
              <xsl:sort select="."/>
            </xsl:perform-sort>
          </xsl:variable>
          <table>
            <tr class="colheads">
              <th class="origin">“Supersetticity” (s5) and aptness as customization starting point (q5) 
                of the item to the right with respect to the item below</th>
              <xsl:for-each select="$all-customizings">
                <th>
                  <xsl:value-of select="."/>
                </th>
              </xsl:for-each>
            </tr>
            <xsl:for-each select="$all-customizings">
              <tr>
                <xsl:variable name="outer" select="." as="xs:string"/>
                <xsl:variable name="outer-customization" as="element(customization)" 
                  select="$context/customization[@name = $outer]"/>
                <xsl:variable name="max-q5" as="xs:string" select="$outer-customization/@max_q5"/>
                <th>
                  <xsl:value-of select="."/>
                </th>
                <xsl:for-each select="$all-customizings">
                  <xsl:variable name="inner" as="xs:string" select="."/>
                  <xsl:variable name="stats-item" as="element(items)?" 
                    select="$outer-customization/items[@not-in = $inner]"/>
                  <td>
                    <xsl:if test="number($stats-item/@q5) = number($max-q5)">
                      <xsl:attribute name="class" select="'max'"/>
                    </xsl:if>
                    <p>
                      <xsl:value-of select="'s5=' || $stats-item/@s5"/>
                    </p>
                    <p>
                      <xsl:value-of select="'q5=' || $stats-item/@q5"/>
                    </p>
                    <p>
                      <xsl:value-of select="'p5=' || $stats-item/@p5"/>
                    </p>
                  </td>
                </xsl:for-each>
              </tr>
            </xsl:for-each>
            <tr class="summary">
              <xsl:variable name="max_s5" as="xs:double" select="max($context/customization/@average_s5)"/>
              <xsl:variable name="max_collection-s5" as="xs:double" select="max($context/customization/@average_collection-s5)"/>
              <xsl:variable name="max_p5" as="xs:double" select="max($context/customization/@average_p5)"/>
              <th>average s5 / collection-only s5 / p5</th>
              <xsl:for-each select="$all-customizings">
                <xsl:variable name="customization" as="element(customization)" 
                  select="$context/customization[@name = current()]"/>
                <td>
                  <p>
                    <xsl:if test="number($customization/@average_s5) = $max_s5">
                      <xsl:attribute name="class" select="'max'"/>
                    </xsl:if>
                    <span class="average">s5</span>=<xsl:value-of select="$customization/@average_s5"/>
                  </p>
                  <p>
                    <xsl:if test="number($customization/@average_collection-s5) = $max_collection-s5">
                      <xsl:attribute name="class" select="'max'"/>
                    </xsl:if>
                    <span class="average">s5<sub>coll</sub></span>=<xsl:value-of select="$customization/@average_collection-s5"/>
                  </p>
                  <p>
                    <xsl:if test="number($customization/@average_p5) = $max_p5">
                      <xsl:attribute name="class" select="'max'"/>
                    </xsl:if>
                    <span class="average">p5</span>=<xsl:value-of select="$customization/@average_p5"/>
                  </p>
                </td>
              </xsl:for-each>
            </tr>
          </table>
        </body>
      </html>
    </xsl:document>
  </xsl:template>

</xsl:stylesheet>
