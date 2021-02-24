<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:html="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="html xs"
  version="3.0">
  <xsl:template match="/">
    <html>
      <head>
        <title>Collection analysis of JohnBenjamins</title>
        <meta charset="utf-8"/>
        <meta name="customization-name" content="JohnBenjamins"/>
      </head>
      <body>
        <h2>Elements</h2>
        <ul id="elements">
          <xsl:apply-templates select="articles/elements/*" mode="elements">
            <xsl:sort select="html:elt-name(.)"/>
          </xsl:apply-templates>
        </ul>
        <h2>Attributes</h2>
        <ul id="attributes">
          <xsl:for-each-group select="articles/elements/*/@*" group-by="html:att-name(.)">
            <xsl:sort select="current-grouping-key()"/>
            <li>
              <xsl:text>@</xsl:text>
              <xsl:value-of select="html:att-name(.)"/>
            </li>
          </xsl:for-each-group>
        </ul>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="*" mode="elements">
    <li>
      <xsl:value-of select="html:elt-name(.)"/>
    </li>
  </xsl:template>
  
  <xsl:function name="html:elt-name" as="xs:string">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:sequence select="string-join(($elt/parent::elements/@prefix, name($elt)), ':')"/>
  </xsl:function>
  
  <xsl:function name="html:att-name" as="xs:string">
    <xsl:param name="att" as="attribute(*)"/>
    <xsl:choose>
      <xsl:when test="name($att) = ('show', 'href', 'title', 'type', 'actuate', 'role')">
        <xsl:sequence select="'xlink:' || name($att)"/>
      </xsl:when>
      <xsl:when test="name($att) = ('base', 'lang', 'space')">
        <xsl:sequence select="'xml:' || name($att)"/>
      </xsl:when>
      <xsl:when test="name($att) = ('noNamespaceSchemaLocation')">
        <xsl:sequence select="'xsi:' || name($att)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="name($att)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>