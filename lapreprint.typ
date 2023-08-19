#let template(
  // The paper's title.
  title: "Paper Title",
  subtitle: none,

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),
  affiliations: (),

  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,
  plain-language-summary: none,
  short-title: none,
  venue: none,
  logo: none,
  after-logo: none,
  doi: none,
  heading-numbering: "1.a.i",
  open-access: true,

  // A list of index terms to display after the abstract.
  keywords: (),
  margin: (),
  paper-size: "us-letter",
  kind: none,
  theme: blue.darken(30%),
  date: datetime.today(),
  date-submitted: none,
  date-accepted: none,
  font-face: "Noto Sans",
  // The paper's content.
  body
) = {

  /* Logos */
  let orcidSvg = ```<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 24 24"> <path fill="#AECD54" d="M21.8,12c0,5.4-4.4,9.8-9.8,9.8S2.2,17.4,2.2,12S6.6,2.2,12,2.2S21.8,6.6,21.8,12z M8.2,5.8c-0.4,0-0.8,0.3-0.8,0.8s0.3,0.8,0.8,0.8S9,7,9,6.6S8.7,5.8,8.2,5.8z M10.5,15.4h1.2v-6c0,0-0.5,0,1.8,0s3.3,1.4,3.3,3s-1.5,3-3.3,3s-1.9,0-1.9,0H10.5v1.1H9V8.3H7.7v8.2h2.9c0,0-0.3,0,3,0s4.5-2.2,4.5-4.1s-1.2-4.1-4.3-4.1s-3.2,0-3.2,0L10.5,15.4z"/></svg>```.text

  let spacer = text(fill: gray)[#h(8pt) | #h(8pt)]

  let sideContent(title, body) = {
    return text(size: 7pt)[
      #text(fill: theme, weight: "bold")[#title]\
      #set enum(indent: 0.1em, body-indent: 0.25em)
      #set list(indent: 0.1em, body-indent: 0.25em)
      #body
    ]
  }


  // Set document metadata.
  set document(title: title, author: authors.map(author => author.name))

  show link: it => [#text(fill: theme)[#it]]
  show ref: it => [#text(fill: theme)[#it]]

  set page(
    paper-size,
    margin: (left: 25%),
    header: locate(loc => {
      if(loc.page() == 1) {
        let headers = (
          if (open-access) {smallcaps[Open Access]},
          if (doi != none) { link("https://doi.org/" + doi, "https://doi.org/" + doi)}
        )
        return align(left, text(size: 8pt, fill: gray, headers.filter(header => header != none).join(spacer)))
      } else {
        return align(right, text(size: 8pt, fill: gray.darken(50%),
          (short-title,[Cockett _et al._, 2023]).join(spacer)
        ))
      }
    }),
    footer: block(
      width: 100%,
      stroke: (top: 1pt + gray),
      inset: (top: 8pt, right: 2pt),
      [
        #grid(columns: (75%, 25%),
          align(left, text(size: 9pt, fill: gray.darken(50%),
              (
                if(venue != none) {emph(venue)},
                if(date != none) {date.display("[month repr:long] [day], [year]")}
              ).filter(t => t != none).join(spacer)
          )),
          align(right)[
            #text(
              size: 9pt, fill: gray.darken(50%)
            )[
              #counter(page).display() of #locate((loc) => {counter(page).final(loc).first()})
            ]
          ]
        )
      ]
    )
  )

  // Set the body font.
  set text(font: font-face, size: 10pt)
  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 1em)

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  set heading(numbering: heading-numbering)
  show heading: it => locate(loc => {
    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    set text(10pt, weight: 400)
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      // We don't want to number of the acknowledgment section.
      #let is-ack = it.body in ([Acknowledgment], [Acknowledgement])
      // #set align(center)
      #set text(if is-ack { 10pt } else { 12pt })
      #show: smallcaps
      #v(20pt, weak: true)
      #if it.numbering != none and not is-ack {
        numbering(heading-numbering, ..levels)
        [.]
        h(7pt, weak: true)
      }
      #it.body
      #v(13.75pt, weak: true)
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #set par(first-line-indent: 0pt)
      #set text(style: "italic")
      #v(10pt, weak: true)
      #if it.numbering != none {
        numbering(heading-numbering, ..levels)
        [.]
        h(7pt, weak: true)
      }
      #it.body
      #v(10pt, weak: true)
    ] else [
      // Third level headings are run-ins too, but different.
      #if it.level == 3 {
        numbering(heading-numbering, ..levels)
        [. ]
      }
      _#(it.body):_
    ]
  })


  if (logo != none or after-logo != none) {
    place(
      top,
      dx: -33%,
      float: false,
      box(
        width: 27%,
        {
          show link: it => [#text(fill: gray.darken(30%))[#it]]
          if (logo != none) {image(logo, width: 100%)}
          after-logo
        },
      ),
    )
  }


  // Title and subtitle
  box(inset: (bottom: 2pt), text(17pt, weight: "bold", fill: theme, title))
  if subtitle != none {
    parbreak()
    box(text(14pt, fill: gray.darken(30%), subtitle))
  }
  // Authors and affiliations
  if authors.len() > 0 {
    box(inset: (y: 10pt), {
      authors.map(author => {
        text(11pt, weight: "semibold", author.name)
        h(1pt)
        if "affiliations" in author {
          super(author.affiliations)
        }
        if "orcid" in author {
          link("https://orcid.org/" + author.orcid)[#box(height: 1.1em, baseline: 13.5%)[#image.decode(orcidSvg)]]
        }
      }).join(", ", last: ", and ")
    })
  }
  if affiliations.len() > 0 {
    box(inset: (bottom: 10pt), {
      affiliations.map(affiliation => {
        super(affiliation.id)
        h(1pt)
        affiliation.name
      }).join(", ")
    })
  }


  place(
    left + bottom,
    dx: -33%,
    dy: -10pt,
    box(width: 27%, {
      if (kind != none) {
        show par: set block(spacing: 0em)
        text(11pt, fill: theme, weight: "semibold", smallcaps(kind))
        parbreak()
      }
      if (date != none) {
        let submittedText = if (date-submitted != none) {
            (
              text(size: 7pt, weight: "light", "Submitted"),
              text(size: 7pt, weight: "light", date-submitted.display("[month repr:short] [day], [year]"))
            )
          } else { none }
        let acceptedText = if (date-accepted != none) {
            (
              text(size: 7pt, weight: "light", "Accepted"),
              text(size: 7pt, weight: "light", date-accepted.display("[month repr:short] [day], [year]"))
            )
          } else { none }
        grid(columns: (40%, 60%), gutter: 7pt,
          text(size: 7pt, fill: theme, weight: "bold", "Published"),
          text(size: 7pt, date.display("[month repr:short] [day], [year]")),
          ..submittedText,
          ..acceptedText,
        )
      }
      v(2em)
      grid(columns: 1, gutter: 2em, ..margin.map(side => sideContent(side.title, side.content)))
    }),
  )


  box(inset: (top: 16pt, bottom: 16pt), stroke: (top: 1pt + gray, bottom: 1pt + gray), {

    set par(justify: true)

    text(fill: theme, weight: "semibold", size: 9pt)[Abstract]
    parbreak()
    abstract

    if (plain-language-summary != none) {
      parbreak()
      text(fill: theme, weight: "semibold", size: 9pt)[Plain Language Summary]
      parbreak()
      plain-language-summary
    }
  })
  if (keywords.len() > 0) {
    text(size: 9pt, {
      text(fill: theme, weight: "semibold", "Keywords")
      h(8pt)
      keywords.join(", ")
    })
  }
  v(10pt)

  show par: set block(spacing: 1.5em)

  // Display the paper's contents.
  body
}
