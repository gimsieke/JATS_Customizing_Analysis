<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">

  <xsl:output indent="yes" method="xhtml"/>

  <xsl:param name="base-dir-uri" as="xs:string"/>
  <xsl:param name="name" as="xs:string?"/>
  <xsl:param name="storage-location" as="xs:string?"/>
  <xsl:param name="cached" as="xs:boolean?"/>

  <xsl:template name="main">
    <xsl:variable name="uris" as="xs:anyURI*" select="uri-collection($base-dir-uri || '?recurse=yes;select=*.xml')"/>
    <xsl:variable name="xml-docs" as="document-node()*"
      select="$uris 
                ! (unparsed-text(.) 
                  => replace('&lt;!DOCTYPE.+?>', ' ', 's') 
                  => replace('&amp;\i\c*;', '') => parse-xml())"/>
    <html>
      <head>
        <title>Collection analysis of
          <xsl:value-of select="xhtml:notdir($base-dir-uri)"/>
        </title>
        <meta charset="utf-8"/>
        <xsl:if test="$name">
          <meta name="customization-name" content="{$name}"/>
        </xsl:if>
        <xsl:if test="$storage-location">
          <meta name="storage-location" content="{$storage-location}"/>
        </xsl:if>
        <xsl:if test="$cached">
          <meta name="cached" content="{$cached}"/>
        </xsl:if>

      </head>
      <body>
        <dl>
          <dt>URIs</dt>
          <dd><xsl:value-of select="count($uris)"/></dd>
          <dt>XMLs</dt>
          <dd><xsl:value-of select="count($xml-docs)"/></dd>
        </dl>
        <h2>Elements</h2>
        <ul>
          <xsl:for-each select="sort(distinct-values($xml-docs//*/name()))">
            <li>
              <xsl:value-of select="."/>
            </li>
          </xsl:for-each>
        </ul>
        <h2>Attributes</h2>
        <ul>
          <xsl:for-each select="sort(distinct-values($xml-docs//@*/name()))">
            <li>
              <xsl:value-of select="'@' || ."/>
            </li>
          </xsl:for-each>
        </ul>
      </body>
    </html>
  </xsl:template>

  <xsl:function name="xhtml:notdir" as="xs:string">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:sequence select="tokenize($uri, '/')[normalize-space()][last()] => replace('_expanded', '') => replace('\.xhtml', '')"/>
  </xsl:function>

</xsl:stylesheet>
