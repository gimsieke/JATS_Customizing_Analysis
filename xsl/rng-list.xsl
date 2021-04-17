<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  version="3.0" exclude-result-prefixes="xs rng">
  
  <xsl:output method="xhtml"/>

  <xsl:param name="name" as="xs:string?"/>
  <xsl:param name="storage-location" as="xs:string?"/>

  <xsl:template match="/">
    <html>
      <head>
        <title>RNG List</title>
        <meta charset="utf-8"/>
        <xsl:if test="$name">
          <meta name="customization-name" content="{$name}"/>
        </xsl:if>
        <xsl:if test="$storage-location">
          <meta name="storage-location" content="{$storage-location}"/>
        </xsl:if>
      </head>
      <body class="schema">
        <xsl:variable name="element-defines" as="element(rng:define)*"
          select="descendant::rng:define[rng:element]
                                        (:[not(starts-with(@name, 'mml.'))
                                         or
                                         @name = 'mml.math']:)"/>
        <h2>Elements</h2>
        <ul id="elements">
          <xsl:apply-templates select="$element-defines" mode="li">
            <xsl:sort select="rng:normalize-sortkey(@name)"/>
          </xsl:apply-templates>
        </ul>
        <h2>Attributes</h2>
        <ul id="attributes">
          <xsl:for-each-group select="descendant::rng:attribute" group-by="@name">
            <xsl:sort select="rng:normalize-sortkey(current-grouping-key())"/>
            <xsl:apply-templates select="." mode="li"/>
          </xsl:for-each-group>
        </ul>
        <h2>Parameter Entities</h2>
        <ul>
          <xsl:variable name="ents" as="element(html:li)*">
            <xsl:apply-templates 
              select="descendant::rng:define[empty(rng:element)]
                                            [not(ends-with(@name, '-attlist'))]
                                            [not(contains(@name, 'mml'))]
                                            [not(contains(base-uri(), '/mathml'))]" mode="li">
<!--              <xsl:sort select="lower-case(@name)"/>-->
              <xsl:sort select="replace(lower-case(@name), '\.', '-')"/>
<!--              <xsl:sort select="generate-id()"/>-->
<!--              <xsl:sort select="rng:normalize-sortkey(@name)"/>-->
              <xsl:with-param name="prefix" as="xs:string" select="'%'"/>
            </xsl:apply-templates>  
          </xsl:variable>
          <xsl:sequence select="$ents"/>
          <xsl:result-document href="parameter-entities.txt" method="text">
            <xsl:sequence select="string-join($ents, '&#xa;')"/>
          </xsl:result-document>
        </ul>
      </body>
    </html>
  </xsl:template>
  
  <xsl:function name="rng:normalize-sortkey" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:sequence select="replace(
                            lower-case($input),
                            '\p{P}',
                            ''
                          )"/>
  </xsl:function>
  
  <xsl:template match="rng:define[rng:element]" mode="li">
    <xsl:param name="prefix" as="xs:string?"/>
    <li>
      <xsl:if test="starts-with((base-uri(.) => tokenize('/'))[last()], 'mathml')">
        <xsl:attribute name="class" select="'mathml'"/>
      </xsl:if>
      <xsl:value-of select="$prefix || rng:element/@name"/>
    </li>
  </xsl:template>
  
  <xsl:template match="rng:define" mode="li">
    <xsl:param name="prefix" as="xs:string?"/>
    <li>
      <xsl:if test="starts-with((base-uri(.) => tokenize('/'))[last()], 'mathml')">
        <xsl:attribute name="class" select="'mathml'"/>
      </xsl:if>
      <xsl:value-of select="$prefix || @name"/>
    </li>
  </xsl:template>
  
  <xsl:template match="rng:attribute" mode="li">
    <li>
      <xsl:if test="starts-with((base-uri(.) => tokenize('/'))[last()], 'mathml')">
        <xsl:attribute name="class" select="'mathml'"/>
      </xsl:if>
      <xsl:value-of select="'@' || @name"/>
    </li>
  </xsl:template>

</xsl:stylesheet>