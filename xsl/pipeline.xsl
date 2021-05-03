<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  exclude-result-prefixes="#all">

  <xsl:param name="base-dir-uri" as="xs:string?">
    <!-- Relative paths in the conf file will be resolved against this URI.
      If it is omitted, the output XHTML file’s URI (or rather, its directory) will be used.
    -->
  </xsl:param>
  
  <xsl:param name="mathml-as-single-item" as="xs:boolean" select="true()"/>

  <xsl:param name="cache" as="xs:boolean" select="true()"/>
  <xsl:param name="top-level-collections-only" as="xs:boolean" select="true()">
    <!-- only relevant for HTML lists that stem from cache-collection elements in the configuration -->
  </xsl:param>
  <xsl:param name="class-lists" as="xs:boolean" select="true()"/>

  <xsl:mode name="mark-as-cached" on-no-match="shallow-copy"/>
  <xsl:mode name="create-content-class-lists" on-no-match="shallow-copy"/>
  <xsl:mode name="cache-collection" on-no-match="shallow-copy"/>

  <xsl:template match="/customization-stats">
    <!-- Child elements:
      collection: @uri is a directory that contains JATS articles
      prefab: @uri points to an XHTML list that is not cached yet OR 
              @uri points to a directory with XHTML lists that are not cached yet
      cache-collection: @uri is a directory that contains XHTML lists that stem from a cache directory
      rng: @uri points to a Relax NG schema 
      -->
    <xsl:variable name="base-dir-uri2" as="xs:string" 
      select="($base-dir-uri, current-output-uri() => replace('[^/]+$', ''))[1]"/>
    <xsl:variable name="html-lists" as="document-node(element(html:html))*">
      <xsl:apply-templates select="*">
        <xsl:with-param name="base-dir-uri2" tunnel="yes" as="xs:string" select="$base-dir-uri2"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="html-lists" as="document-node(element(html:html))*">
      <xsl:sequence select="$html-lists"/>
      <!-- Create HTML lists for each content class. They will be stored at arbitrary locations
        (where the first “real” HTML list file with each class was located) -->
      <xsl:if test="$class-lists">
         <xsl:for-each-group 
           select="$html-lists[
                     html:html[
                       empty(html:head/html:meta[@name = 'pre-generated-summary'])
                     ]/html:body[@class[not(. = ('schema', ''))]]
                   ]" 
           group-by="html:html/html:body/@class">
           <xsl:apply-templates select="." mode="create-content-class-lists">
             <xsl:with-param name="all-lists" as="document-node(element(html:html))+" select="current-group()" tunnel="yes"/>
             <xsl:with-param name="customization-name" as="xs:string" select="current-grouping-key()" tunnel="yes"/>
           </xsl:apply-templates>
         </xsl:for-each-group>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="html-lists" as="document-node(element(html:html))*">
      <!-- Optionally only use top-level collections, in order not to clutter the comparison tables with
        rows/columns for each sub-collection -->
      <xsl:choose>
        <xsl:when test="$top-level-collections-only">
          <xsl:sequence select="$html-lists[html:html/html:body/@class =  
                                 html:html/html:head/html:meta[@name='customization-name']/@content]
                                |
                                $html-lists[html:html/html:head/html:meta[@name='is-top-level-collection']/@content = 'true']
                                |
                                $html-lists[empty(html:html/html:head/html:meta[@name='cache-collection-uri'])]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$html-lists"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:for-each select="$html-lists[not(html:html/html:head/html:meta[@name = 'cached']/@content = ('true', 'exclude'))]">
      <!-- Write HTML lists into th cache directory (unless they have already been read from the cache as 
        per their 'cached' meta element) -->
      <xsl:variable name="storage-location" as="xs:string*" 
        select="html:html/html:head/html:meta[@name='storage-location']/@content"/>
      <xsl:if test="empty($storage-location)">
        <xsl:message terminate="yes" 
          select="'A meta element with the name ''storage-location'' must be present unless the meta element named ''cached'' is ''true'' or ''exclude''. All meta elements: ', 
          html:html/html:head/html:meta"/>
      </xsl:if>
      <xsl:if test="count($storage-location) gt 1">
        <xsl:message terminate="yes" 
          select="'More than one ''storage-location''. All meta elements: ', html:html/html:head"/>
      </xsl:if>
      <xsl:result-document method="xhtml" 
        href="{html:html/html:head/html:meta[@name='storage-location'][1]/@content}">
        <xsl:apply-templates select="." mode="mark-as-cached"/>
      </xsl:result-document>
    </xsl:for-each>

    <xsl:variable name="stats" as="map(xs:string, item())" 
      select="transform(map{
                             'stylesheet-location': 'stats.xsl',
                             'initial-template': xs:QName('main'),
                             'stylesheet-params': map{
                                                       xs:QName('html-docs'): $html-lists,
                                                       xs:QName('base-dir-uri'): $base-dir-uri2,
                                                       xs:QName('primary-output-uri'): current-output-uri(),
                                                       xs:QName('mathml-as-single-item'): $mathml-as-single-item,
                                                       xs:QName('conf-file'): base-uri()
                                                     }
                           })"/>
    <xsl:for-each select="map:keys($stats)[not(. = 'output')]">
      <xsl:result-document href="{.}">
        <xsl:sequence select="$stats(.)"/>
      </xsl:result-document>
    </xsl:for-each>
    <xsl:result-document href="{current-output-uri() => replace('\.[^.]+$', '.csv')}" method="text">
      <xsl:apply-templates select="$stats?output//xhtml:table" mode="csv"/>
    </xsl:result-document>
    <xsl:sequence select="$stats?output"/>
  </xsl:template>
  
  <xsl:template match="xhtml:table" mode="csv" xmlns="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="xhtml:tr except (xhtml:tr[1] union xhtml:tr[last()])" mode="#current"/>
  </xsl:template>

  <xsl:template match="xhtml:tr" mode="csv" xmlns="http://www.w3.org/1999/xhtml">
    <xsl:value-of select="normalize-space(*[1]/text()[1])"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="*[last() -3]"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="'+' || *[last()]"/>
    <xsl:text>&#13;&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="html:head/html:meta[last()]" mode="mark-as-cached">
    <xsl:next-match/>
    <meta xmlns="http://www.w3.org/1999/xhtml" name="cached" content="true"/>
  </xsl:template>
  
  <xsl:template match="rng">
    <xsl:param name="base-dir-uri2" as="xs:string" tunnel="yes"/>
    <xsl:variable name="file-uri" as="xs:anyURI" select="resolve-uri(@uri, $base-dir-uri2 || '/')"/>
    <xsl:variable name="html-list-uri" as="xs:anyURI" select="html:cache-uri(@uri, $base-dir-uri2)"/>
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
  
  <xsl:function name="html:cache-uri" as="xs:anyURI">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:param name="base-dir-uri" as="xs:string"/>
    <xsl:if test="contains($uri, '\')">
      <xsl:message terminate="yes" select="'URI must not contain a backslash: ', $uri"/>
    </xsl:if>
    <xsl:variable name="relative" as="xs:string" 
      select="if (starts-with($uri, '/') or contains($uri, ':'))
              then replace($uri, '^([a-z]*:/+)+', '', 'i') (: drive letter or file: :)
              else $uri => replace('^(../)+', '')"/>
    <xsl:variable name="html-file-name" as="xs:string" 
      select="if (matches($relative, '\.xhtml$'))
              then $relative
              else if (matches($relative, '\.rng$', 'i'))
                   then replace($relative, '\.rng$', '.xhtml')
                   else replace($relative, '(.+?)/*$', '$1.xhtml')"/>
    <xsl:sequence select="resolve-uri($html-file-name, $base-dir-uri || '/cache/')"/>
  </xsl:function>
  
  <xsl:template match="cache-collection">
    <xsl:param name="base-dir-uri2" tunnel="yes" as="xs:string"/>
    <xsl:variable name="cache-collection-uri" as="xs:string" 
      select="string(resolve-uri(@uri, $base-dir-uri2 || '/'))"/>
    <xsl:variable name="top-level-uris" as="xs:string*" 
      select="uri-collection($cache-collection-uri || '?select=*.xhtml') ! string(.)"/>
    <xsl:variable name="collection-member-lists" as="document-node(element(html:html))*">
      <xsl:apply-templates select="collection($cache-collection-uri || '?recurse=yes;select=*.xhtml')
                              [not(html:html/html:body/@class = (: suppress generated per-class customization lists :) 
                                   html:html/html:head/html:meta[@name='customization-name']/@content)]" mode="cache-collection">
        <xsl:with-param name="cache-collection-uri" tunnel="yes" as="xs:string" select="$cache-collection-uri"/>
        <xsl:with-param name="top-level-uris" tunnel="yes" as="xs:string*" select="$top-level-uris"/>
      </xsl:apply-templates>  
    </xsl:variable>
    <xsl:sequence select="$collection-member-lists"/>
    <xsl:apply-templates select="$collection-member-lists[1]" mode="create-content-class-lists">
      <xsl:with-param name="all-lists" as="document-node(element(html:html))+" select="$collection-member-lists" tunnel="yes"/>
      <xsl:with-param name="customization-name" as="xs:string" select="@name" tunnel="yes"/>
      <xsl:with-param name="class" as="xs:string" select="@name" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="collection | prefab">
    <xsl:param name="base-dir-uri2" as="xs:string" tunnel="yes"/>
    <xsl:variable name="uri" as="xs:anyURI" select="resolve-uri(@uri, $base-dir-uri2 || '/')"/>
    <xsl:variable name="html-list-uri" as="xs:anyURI" select="html:cache-uri(@uri, $base-dir-uri2)"/>
    <xsl:choose>
      <xsl:when test="doc-available($html-list-uri)">
        <xsl:sequence select="doc($html-list-uri)"/>
      </xsl:when>
      <xsl:when test="self::collection">
        <xsl:variable name="html-list" as="document-node(element(html:html))"
          select="transform(
                    map{
                      'initial-template': xs:QName('main'), 
                      'stylesheet-location': 'collection-list.xsl',
                      'stylesheet-params': map{
                                                xs:QName('base-dir-uri'): $uri,
                                                xs:QName('name'): @name,
                                                xs:QName('storage-location'): $html-list-uri,
                                                xs:QName('content-class'): @class
                                              }
                    }
                  )?output"/>
        <xsl:sequence select="$html-list"/>
      </xsl:when>
      <xsl:when test="exists(self::prefab) and not(doc-available($uri))"><!-- prefab/@uri probably points to a directory -->
        <xsl:variable name="html-list-uris" as="xs:string*" select="uri-collection($uri || '?select=*.xhtml') ! string(.)"/>
        <xsl:variable name="cached-lists" as="document-node(element(html:html))*">
          <xsl:for-each select="$html-list-uris">
            <xsl:variable name="html-list" as="document-node(element(html:html))" select="doc(.)"/>
            <xsl:variable name="relative" as="xs:string" select="substring-after(., $base-dir-uri2)"/>
            <xsl:sequence
              select="transform(
                        map{
                          'source-node': doc(.), 
                          'stylesheet-location': 'prefab-list.xsl',
                          'stylesheet-params': map{
                                                    xs:QName('name'): $html-list/html:html/html:head/html:meta[@name='customization-name']/@content,
                                                    xs:QName('storage-location'): html:cache-uri($relative, $base-dir-uri2),
                                                    xs:QName('cached'): false()
                                                  }
                        }
                      )?output"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="$cached-lists"/>
        <xsl:variable name="classes" as="xs:string*" select="distinct-values($cached-lists/html:html/html:body/@class)"/>
        <xsl:apply-templates select="$cached-lists[1]" mode="create-content-class-lists">
          <xsl:with-param name="all-lists" as="document-node(element(html:html))+" select="$cached-lists" tunnel="yes"/>
          <xsl:with-param name="customization-name" as="xs:string" select="@name" tunnel="yes"/>
          <xsl:with-param name="class" as="xs:string" select="if (count($classes) = 1) then $classes else ''" tunnel="yes"/>
        </xsl:apply-templates>  
      </xsl:when>
      <xsl:otherwise><!-- prefab/@uri points to an XHTML list -->
        <xsl:variable name="html-list" as="document-node(element(html:html))"
          select="transform(
                    map{
                      'source-node': doc($uri), 
                      'stylesheet-location': 'prefab-list.xsl',
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
  
  
  <xsl:template match="html:meta[@name='storage-location']/@content" mode="create-content-class-lists">
    <xsl:param name="customization-name" as="xs:string" tunnel="yes"/>
    <xsl:attribute name="{name()}" select="replace(., '^(.+)/(.+)(\.xhtml)$', concat('$1/', $customization-name, '$3'))"/>
  </xsl:template>
  
  <xsl:template match="html:meta[@name='customization-name']/@content" mode="create-content-class-lists">
    <xsl:param name="customization-name" as="xs:string" tunnel="yes"/>
    <xsl:attribute name="{name()}" select="$customization-name"/>
  </xsl:template>
  
  <xsl:template match="html:meta[@name='cached']/@content" mode="create-content-class-lists" priority="4">
    <xsl:attribute name="{name()}" select="'exclude'"/>
  </xsl:template>
  
  <xsl:template match="html:meta[@name='cached']" mode="cache-collection" priority="4">
    <xsl:param name="cache-collection-uri" as="xs:string" tunnel="yes"/>
    <xsl:param name="top-level-uris" as="xs:string*" tunnel="yes"/>
    <xsl:copy>
      <xsl:copy-of select="@name"/>
      <xsl:attribute name="content" select="'exclude'"/>
    </xsl:copy>
    <meta xmlns="http://www.w3.org/1999/xhtml" name="cache-collection-uri" content="{$cache-collection-uri}"/>
    <xsl:if test="base-uri() = $top-level-uris">
      <meta xmlns="http://www.w3.org/1999/xhtml" name="is-top-level-collection" content="true"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="html:head" mode="cache-collection">
    <xsl:if test="empty(html:meta[@name='cached'])">
      <xsl:message terminate="yes" 
          select="'Cache collection members must have a ''cached'' meta element. All meta elements: ', html:meta"/>
    </xsl:if>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="html:ul[@id = ('attributes', 'elements')]" mode="create-content-class-lists">
    <xsl:param name="all-lists" as="document-node(element(html:html))+" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="$all-lists//html:ul[@id = current()/@id]/html:li" group-by="string(.)">
        <xsl:apply-templates select="." mode="#current"/>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="html:body" mode="create-content-class-lists">
    <xsl:param name="class" as="xs:string?" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="exists($class)">
        <xsl:copy>
          <xsl:apply-templates select="@* except @class" mode="#current"/>
          <xsl:attribute name="class" select="$class"/>
          <xsl:apply-templates mode="#current"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="html:meta[last()]" mode="create-content-class-lists" priority="5">
    <xsl:param name="class" as="xs:string?" tunnel="yes"/>
    <xsl:next-match/>
    <xsl:if test="$class">
      <meta xmlns="http://www.w3.org/1999/xhtml" name="pre-generated-summary" content="{$class}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="html:meta[@name='is-top-level-collection']" mode="create-content-class-lists"/>

</xsl:stylesheet>
