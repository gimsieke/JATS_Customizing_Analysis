<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  exclude-result-prefixes="#all">
  
  <xsl:output indent="yes" method="xml"/>
  
  <xsl:param name="base-dir-uri" as="xs:string"/>
  
  <xsl:template name="main">
    <xsl:variable name="html-docs" as="document-node()*" 
      select="collection($base-dir-uri || '?recurse=yes;select=*.xhtml')"/>
    <xsl:variable name="element-lists" as="element(xhtml:ul)*" select="$html-docs/xhtml:html/xhtml:body/xhtml:ul[1]"/>
    <xsl:message select="'Counts: ', $element-lists ! count(xhtml:li)"/>
    <customizings>
      <xsl:for-each select="$element-lists">
        <xsl:variable name="outer" as="element(xhtml:ul)" select="."/>
        <customizing name="{xhtml:notdir(base-uri($outer))}" element-count="{count(xhtml:li)}">
          <xsl:for-each select="$element-lists except $outer">
            <xsl:variable name="inner" as="element(xhtml:ul)" select="."/>
            <elements not-in="{xhtml:notdir(base-uri($inner))}">
              <xsl:value-of select="$outer/xhtml:li[not(. = $inner/xhtml:li)]"/>
            </elements>
          </xsl:for-each>  
        </customizing>
      </xsl:for-each>
    </customizings>
    
  </xsl:template>
  
  <xsl:function name="xhtml:notdir" as="xs:string">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:sequence select="tokenize($uri, '/')[last()]"/>
  </xsl:function>
  
</xsl:stylesheet>