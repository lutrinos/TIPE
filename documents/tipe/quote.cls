<?xml version="1.0" encoding="utf-8"?>
<style xmlns="http://purl.org/net/xbiblio/csl" class="in-text" version="1.0" demote-non-dropping-particle="sort-only">
  <info>
    <title>SCEI TIPE 2026</title>
    <id>http://www.zotero.org/styles/scei-tipe</id>
    <link href="http://www.zotero.org/styles/scei-tipe" rel="self"/>
    <link href="https://www.scei-concours.fr/pdf/TIPE_2026_Attendus_Pedagogiques.pdf" rel="documentation"/>
    <author>
      <name>Claude</name>
    </author>
    <category citation-format="numeric"/>
    <category field="science"/>
    <summary>Style bibliographique pour le TIPE SCEI selon les attendus pédagogiques 2026</summary>
    <updated>2025-01-01T00:00:00+00:00</updated>
  </info>
  
  <locale xml:lang="fr">
    <terms>
      <term name="accessed">consulté le</term>
      <term name="editor" form="short">éd.</term>
    </terms>
  </locale>
  
  <macro name="author">
    <names variable="author">
      <name name-as-sort-order="all" sort-separator=" " initialize-with=". " delimiter=", " delimiter-precedes-last="always"/>
      <label form="short" prefix=" (" suffix=")"/>
      <substitute>
        <names variable="editor"/>
        <names variable="translator"/>
        <text variable="container-title"/>
      </substitute>
    </names>
  </macro>
  
  <macro name="editor">
    <names variable="editor">
      <name name-as-sort-order="all" sort-separator=" " initialize-with=". " delimiter=", "/>
      <label form="short" prefix=" (" suffix=")"/>
    </names>
  </macro>
  
  <macro name="title">
    <text variable="title"/>
  </macro>
  
  <macro name="publisher">
    <group delimiter=", ">
      <text variable="publisher"/>
      <text variable="publisher-place"/>
    </group>
  </macro>
  
  <macro name="year">
    <date variable="issued" prefix="(" suffix=")">
      <date-part name="year"/>
    </date>
  </macro>
  
  <macro name="edition">
    <choose>
      <if is-numeric="edition">
        <group delimiter=" ">
          <number variable="edition" form="ordinal"/>
          <text term="edition" form="short"/>
        </group>
      </if>
      <else>
        <text variable="edition"/>
      </else>
    </choose>
  </macro>
  
  <macro name="access">
    <choose>
      <if variable="URL">
        <group delimiter=", ">
          <text variable="URL"/>
          <group delimiter=" ">
            <text term="accessed" text-case="capitalize-first"/>
            <date variable="accessed" delimiter=" ">
              <date-part name="day"/>
              <date-part name="month"/>
              <date-part name="year"/>
            </date>
          </group>
        </group>
      </if>
    </choose>
  </macro>
  
  <citation collapse="citation-number">
    <sort>
      <key variable="citation-number"/>
    </sort>
    <layout prefix="[" suffix="]" delimiter=",">
      <text variable="citation-number"/>
    </layout>
  </citation>
  
  <bibliography entry-spacing="0" second-field-align="flush">
    <layout suffix=".">
      <text variable="citation-number" prefix="[" suffix="] "/>
      
      <choose>
        <!-- Livre / Ouvrage -->
        <if type="book">
          <group delimiter=" ">
            <text macro="author"/>
            <text macro="title" font-style="italic"/>
            <text macro="edition"/>
            <text macro="publisher"/>
            <text macro="year"/>
            <text variable="ISBN" prefix="ISBN: "/>
          </group>
        </if>
        
        <!-- Article de périodique -->
        <else-if type="article-journal">
          <group delimiter=" ">
            <text macro="author"/>
            <text macro="title"/>
            <text variable="container-title" font-style="italic" suffix=","/>
            <group delimiter=", ">
              <text variable="volume"/>
              <date variable="issued" prefix="(" suffix=")">
                <date-part name="year"/>
              </date>
              <text variable="page"/>
            </group>
            <text variable="DOI" prefix="DOI: "/>
          </group>
        </else-if>
        
        <!-- Site web -->
        <else-if type="webpage">
          <group delimiter=" ">
            <text macro="author"/>
            <text macro="title"/>
            <text macro="access"/>
          </group>
        </else-if>
        
        <!-- Article de conférence -->
        <else-if type="paper-conference">
          <group delimiter=" ">
            <text macro="author"/>
            <text macro="title"/>
            <text variable="container-title" font-style="italic" suffix=","/>
            <group delimiter=", ">
              <date variable="issued" prefix="(" suffix=")">
                <date-part name="year"/>
              </date>
              <text variable="publisher-place"/>
            </group>
          </group>
        </else-if>
        
        <!-- Chapitre de livre -->
        <else-if type="chapter">
          <group delimiter=" ">
            <text macro="author"/>
            <text macro="title"/>
            <text term="in" text-case="lowercase"/>
            <text variable="container-title" font-style="italic"/>
            <text macro="editor"/>
            <text macro="publisher"/>
            <text macro="year"/>
            <text variable="page" prefix="p. "/>
          </group>
        </else-if>
        
        <!-- Défaut -->
        <else>
          <group delimiter=" ">
            <text macro="author"/>
            <text macro="title"/>
            <text variable="container-title" font-style="italic"/>
            <text macro="year"/>
          </group>
        </else>
      </choose>
    </layout>
  </bibliography>
</style>