<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  exclude-result-prefixes="#all">

  <xsl:param name="base-dir-uri" as="xs:string"/>

  <xsl:param name="cache" as="xs:boolean" select="true()"/>

  <xsl:template match="/customization-stats">
    <xsl:variable name="html-lists" as="document-node(element(html:html))*">
      <xsl:apply-templates select="*"/>
    </xsl:variable>
    <xsl:for-each select="$html-lists[empty(html:html/html:head/html:meta">
      <xsl:result-document method="xhtml" 
        href="{replace(//html:meta[@name='storage-location']/@content, '(.+/)', '$1/')}">
        <!-- trick saxon into writing the html doc (that it potentially read as input) 
          by duplicating the last slash in the uri -->
        <xsl:sequence select="."/>
      </xsl:result-document>
    </xsl:for-each>
    <xsl:message select="count($html-lists), $html-lists ! (.//html:meta[@name='customization-name']/@content, count(.//html:li))"></xsl:message>
  </xsl:template>
  
  <xsl:template match="rng">
    <xsl:variable name="file-uri" as="xs:anyURI" select="resolve-uri(@uri, $base-dir-uri || '/')"/>
    <xsl:variable name="html-list-uri" as="xs:string" select="replace($file-uri, '\.rng$', '.xhtml')"/>
    <xsl:choose>
      <xsl:when test="doc-available($html-list-uri)">
        <xsl:sequence select="doc($html-list-uri)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="schema-doc" as="document-node(element(rng:grammar))"
          select="doc($file-uri)"/>
        <xsl:variable name="expand-includes" as="document-node(element(rng:grammar))"
          select="transform(map{'source-node':$schema-doc, 'stylesheet-location': 'rng-expand-includes.xsl'})?output"/>
        <xsl:variable name="expand-refs" as="document-node(element(rng:grammar))"
          select="transform(
                    map{
                      'source-node':$expand-includes, 
                      'stylesheet-location': 'rng-expand-refs.xsl',
                      'initial-mode': xs:QName('expand-refs')
                    }
                  )?output"/>
        <xsl:variable name="html-list" as="document-node(element(html:html))"
          select="transform(
                    map{
                      'source-node':$expand-refs, 
                      'stylesheet-location': 'rng-list.xsl',
                      'stylesheet-params': map{
                                             xs:QName('name'): @name,
                                             xs:QName('storage-location'): $html-list-uri
                                           }
                    }
                  )?output"/>
        <xsl:sequence select="$html-list"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
