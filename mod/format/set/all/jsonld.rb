format :jsonld do
    # Default: JSON-LD not supported (can be overridden by any set)
    def jsonld_supported_collection? = false

    def jsonld_error(status: 406, description:)
        response.status = status
        response.headers["Content-Type"] = "application/ld+json"
        {
            "@context": "https://www.w3.org/ns/hydra/core#",
            "@type": "hydra:Error",
            "hydra:title": (status == 415 ? "Unsupported Media Type" : "Not Acceptable"),
            "hydra:description": description
        }.to_json
    end

    view :items, cache: :never do
        listing_list item_cards, view: voo_items_view || :molecule
    end

    def show view, args
        return jsonld_error(description: "JSON-LD is not available for this cardtype.") unless jsonld_supported_collection?

        view = :molecule
        string_with_page_details do
            render! view, args
        end
    end

    def molecule
        {
            "@id": path,
            "@context": "https://www.w3.org/ns/hydra/core#",
            "@type": "hydra:Collection",
            "hydra:member": _render_items
        }.compact
    end
end