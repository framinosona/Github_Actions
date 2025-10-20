#!/usr/bin/env bash

# 🏷️ Generate Badge - Shell Version

set -euo pipefail

# Default values
LABEL=""
MESSAGE=""
COLOR="blue"
LABEL_COLOR=""
STYLE="flat"
LOGO=""
LOGO_COLOR=""
LOGO_SIZE=""
OUTPUT_FILE=""
OUTPUT_FORMAT="svg"
CACHE_SECONDS=""
VERBOSE=false

# Script information
SCRIPT_NAME="$(basename "$0")"
SCRIPT_VERSION="1.0.0"

# Function to display help
show_help() {
    cat << EOF
🏷️ Generate Badge - Shell Script Version v${SCRIPT_VERSION}
Generate static badges using shields.io with customizable styling and output options

USAGE:
    ${SCRIPT_NAME} [OPTIONS] --message "Your message"

REQUIRED PARAMETERS:
    -m, --message TEXT          Right-hand side text/message of the badge

OPTIONAL PARAMETERS:
    -l, --label TEXT            Left-hand side text of the badge
    -c, --color COLOR           Background color of the right part (default: blue)
                                Supports: hex, rgb, rgba, hsl, hsla, css named colors
    --label-color COLOR         Background color of the left part
    -s, --style STYLE           Badge style (default: flat)
                                Options: flat, flat-square, plastic, for-the-badge, social
    --logo SLUG                 Icon slug from simple-icons (e.g., github, docker, node-dot-js)
    --logo-color COLOR          Color of the logo
    --logo-size SIZE            Logo size - set to "auto" for adaptive resizing
    -o, --output-file PATH      File path to save the badge content
    -f, --output-format FORMAT  Output format (default: svg)
                                Options: url, markdown, html, svg
    --cache-seconds SECONDS     HTTP cache lifetime in seconds
    -v, --verbose              Enable verbose output
    -h, --help                 Show this help message

EXAMPLES:
    # Basic usage
    ${SCRIPT_NAME} --message "passing" --color "green"

    # With label and custom style
    ${SCRIPT_NAME} --label "tests" --message "passing" --style "flat-square" --color "brightgreen"

    # Generate markdown format with logo
    ${SCRIPT_NAME} --message "v1.0.0" --logo "github" --output-format "markdown"

    # Save to file
    ${SCRIPT_NAME} --message "build passing" --output-file "./badge.svg"

    # Full example with all options
    ${SCRIPT_NAME} \\
        --label "coverage" \\
        --message "85%" \\
        --color "yellow" \\
        --label-color "gray" \\
        --style "for-the-badge" \\
        --logo "codecov" \\
        --logo-color "white" \\
        --output-format "svg" \\
        --output-file "./coverage-badge.svg" \\
        --verbose

COLORS:
    Named colors: red, orange, yellow, green, brightgreen, blue, lightblue, etc.
    Hex colors: Use without # (e.g., ff0000 for red)
    RGB/RGBA/HSL/HSLA: Supported by shields.io

AUTHOR:
    Francois Raminosona

EOF
}

# Function for verbose logging
log_verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "🔍 [VERBOSE] $*" >&2
    fi
}

# Function for error logging
log_error() {
    echo "❌ [ERROR] $*" >&2
}

# Function for info logging
log_info() {
    echo "ℹ️  [INFO] $*" >&2
}

# Function to URL encode text
url_encode() {
    local string="$1"
    # Shields.io specific encoding for badge content
    # Replace spaces with %20, underscores with __, and hyphens with --
    # Also handle other special characters that could break URLs
    echo "$string" | sed 's/ /%20/g' | sed 's/_/__/g' | sed 's/-/--/g' | \
        sed 's/%/%25/g' | sed 's/&/%26/g' | sed 's/?/%3F/g' | \
        sed 's/#/%23/g' | sed 's/\[/%5B/g' | sed 's/\]/%5D/g' | \
        sed 's/{/%7B/g' | sed 's/}/%7D/g' | sed 's/|/%7C/g' | \
        sed 's/\\/%5C/g' | sed 's/\^/%5E/g' | sed 's/`/%60/g'
}

# Function to URL encode query parameters (more strict)
url_encode_param() {
    local string="$1"
    # Use printf and od for proper URL encoding of query parameters
    printf '%s' "$string" | od -An -tx1 | tr ' ' '%' | tr -d '\n' | sed 's/%$//' | sed 's/%/%25/g; s/%%/%/g'
}

# Function to sanitize input strings
sanitize_input() {
    local input="$1"
    local max_length="${2:-100}"  # Default max length of 100 chars

    # Remove control characters, limit length, trim whitespace
    echo "$input" | tr -d '\000-\037\177' | head -c "$max_length" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Function to validate style parameter
validate_style() {
    case "$1" in
        flat|flat-square|plastic|for-the-badge|social)
            return 0
            ;;
        *)
            log_error "Invalid style '$1'. Must be one of: flat, flat-square, plastic, for-the-badge, social"
            return 1
            ;;
    esac
}

# Function to validate output format
validate_output_format() {
    case "$1" in
        url|markdown|html|svg)
            return 0
            ;;
        *)
            log_error "Invalid output format '$1'. Must be one of: url, markdown, html, svg"
            return 1
            ;;
    esac
}

# Function to validate cache seconds
validate_cache_seconds() {
    if [[ ! "$1" =~ ^[0-9]+$ ]]; then
        log_error "cache-seconds must be a numeric value, got '$1'"
        return 1
    fi

    # Check reasonable bounds (1 second to 1 year)
    local seconds="$1"
    if (( seconds < 1 || seconds > 31536000 )); then
        log_error "cache-seconds must be between 1 and 31536000 (1 year), got '$seconds'"
        return 1
    fi
    return 0
}

# Function to validate color format
validate_color() {
    local color="$1"
    local color_type="${2:-color}"  # 'color' or 'label-color'

    # Empty color is valid (uses default)
    if [[ -z "$color" ]]; then
        return 0
    fi

    # Check for hex colors (3 or 6 digits, without #)
    if [[ "$color" =~ ^[0-9a-fA-F]{3}$ ]] || [[ "$color" =~ ^[0-9a-fA-F]{6}$ ]]; then
        return 0
    fi

    # Check for named colors (shields.io supported colors)
    case "$color" in
        red|orange|yellow|green|brightgreen|blue|lightblue|gray|grey|black|white|pink|purple|brown|darkgreen|darkblue|darkred|darkorange|darkgray|darkgrey|lightgray|lightgrey|cyan|magenta|lime|olive|navy|teal|silver|maroon|fuchsia|aqua)
            return 0
            ;;
        *)
            log_error "Invalid $color_type format: "$color". Use hex (without #) or named colors"
            return 1
            ;;
    esac
}

# Function to validate logo slug
validate_logo() {
    local logo="$1"

    # Empty logo is valid
    if [[ -z "$logo" ]]; then
        return 0
    fi

    # Logo slug should follow shields.io formatting rules:
    # - Start and end with alphanumeric characters
    # - Dots and hyphens only between alphanumeric sequences
    # - No consecutive dots or hyphens
    if [[ ! "$logo" =~ ^[a-z0-9]+([.-][a-z0-9]+)*$ ]]; then
        log_error "Invalid logo slug: "$logo". Must start/end with alphanumeric and use dots/hyphens only between sequences"
        return 1
    fi

    return 0
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()

    # Check for curl or wget
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        missing_deps+=("curl or wget")
    fi

    # Check for basic utilities
    for cmd in sed head od printf; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        return 1
    fi

    return 0
}

# Function to validate inputs
validate_inputs() {
    log_verbose "Validating inputs..."

    # Check dependencies first
    if ! check_dependencies; then
        return 1
    fi

    # Validate required message parameter
    if [[ -z "$MESSAGE" ]]; then
        log_error "Message parameter is required. Use --message 'your message'"
        return 1
    fi

    # Sanitize inputs
    MESSAGE=$(sanitize_input "$MESSAGE" 50)
    LABEL=$(sanitize_input "$LABEL" 30)
    COLOR=$(sanitize_input "$COLOR" 20)
    LABEL_COLOR=$(sanitize_input "$LABEL_COLOR" 20)
    LOGO=$(sanitize_input "$LOGO" 30)
    LOGO_COLOR=$(sanitize_input "$LOGO_COLOR" 20)

    # Validate message is not empty after sanitization
    if [[ -z "$MESSAGE" ]]; then
        log_error "Message parameter is empty after sanitization"
        return 1
    fi

    # Validate style parameter
    if [[ -n "$STYLE" ]]; then
        if ! validate_style "$STYLE"; then
            return 1
        fi
    fi

    # Validate output format
    if [[ -n "$OUTPUT_FORMAT" ]]; then
        if ! validate_output_format "$OUTPUT_FORMAT"; then
            return 1
        fi
    fi

    # Validate colors
    if ! validate_color "$COLOR" "color"; then
        return 1
    fi

    if ! validate_color "$LABEL_COLOR" "label-color"; then
        return 1
    fi

    if ! validate_color "$LOGO_COLOR" "logo-color"; then
        return 1
    fi

    # Validate logo
    if ! validate_logo "$LOGO"; then
        return 1
    fi

    # Validate output file directory exists if specified
    if [[ -n "$OUTPUT_FILE" ]]; then
        local output_dir
        output_dir=$(dirname "$OUTPUT_FILE")
        if [[ ! -d "$output_dir" ]]; then
            log_info "Creating output directory: $output_dir"
            if ! mkdir -p "$output_dir"; then
                log_error "Failed to create output directory: $output_dir"
                return 1
            fi
        fi
    fi

    # Validate cache-seconds is numeric if specified
    if [[ -n "$CACHE_SECONDS" ]]; then
        if ! validate_cache_seconds "$CACHE_SECONDS"; then
            return 1
        fi
    fi

    log_verbose "Input validation passed"
    return 0
}

# Function to generate badge URL
generate_badge_url() {
    log_verbose "Generating shields.io badge..."

    # Build badge content
    local badge_content
    if [[ -n "$LABEL" ]]; then
        # Label-Message-Color format
        local label_encoded message_encoded
        label_encoded=$(url_encode "$LABEL")
        message_encoded=$(url_encode "$MESSAGE")
        badge_content="${label_encoded}-${message_encoded}-${COLOR}"
    else
        # Message-Color format
        local message_encoded
        message_encoded=$(url_encode "$MESSAGE")
        badge_content="${message_encoded}-${COLOR}"
    fi

    # Build base URL
    local base_url="https://img.shields.io/badge/${badge_content}"

    # Build query parameters
    local params=""

    # Add style parameter
    if [[ -n "$STYLE" && "$STYLE" != "flat" ]]; then
        params="${params}&style=${STYLE}"
    fi

    # Add logo parameters
    if [[ -n "$LOGO" ]]; then
        params="${params}&logo=${LOGO}"
    fi

    if [[ -n "$LOGO_COLOR" ]]; then
        params="${params}&logoColor=${LOGO_COLOR}"
    fi

    if [[ -n "$LOGO_SIZE" ]]; then
        params="${params}&logoSize=${LOGO_SIZE}"
    fi

    # Add label color
    if [[ -n "$LABEL_COLOR" ]]; then
        params="${params}&labelColor=${LABEL_COLOR}"
    fi

    # Add cache seconds
    if [[ -n "$CACHE_SECONDS" ]]; then
        params="${params}&cacheSeconds=${CACHE_SECONDS}"
    fi

    # Remove leading & if params exist
    if [[ -n "$params" ]]; then
        params="?${params#&}"
    fi

    # Complete URL
    local badge_url="${base_url}${params}"

    log_verbose "Generated badge URL: $badge_url"
    echo "$badge_url"
}

# Function to generate different output formats
generate_output_formats() {
    local badge_url="$1"
    local alt_text

    if [[ -n "$LABEL" ]]; then
        alt_text="${LABEL}: ${MESSAGE}"
    else
        alt_text="${MESSAGE}"
    fi

    case "$OUTPUT_FORMAT" in
        url)
            echo "$badge_url"
            ;;
        markdown)
            echo "![${alt_text}](${badge_url})"
            ;;
        html)
            echo "<img src=\"${badge_url}\" alt=\"${alt_text}\" />"
            ;;
        svg)
            download_svg_content "$badge_url"
            ;;
    esac
}

# Function to download SVG content
download_svg_content() {
    local badge_url="$1"
    log_verbose "Downloading SVG content from shields.io..."

    local svg_content
    local http_code
    local temp_file
    temp_file=$(mktemp)

    if command -v curl >/dev/null 2>&1; then
        # Use curl with timeout, follow redirects, and capture HTTP status
        if ! http_code=$(curl -s --max-time 30 --connect-timeout 10 -L -w "%{http_code}" -o "$temp_file" "$badge_url"); then
            log_error "curl command failed"
            rm -f "$temp_file"
            return 1
        fi
        svg_content=$(cat "$temp_file")
    elif command -v wget >/dev/null 2>&1; then
        # Use wget with timeout and save to temp file
        if ! wget --timeout=30 --connect-timeout=10 -q -O "$temp_file" "$badge_url"; then
            log_error "wget command failed"
            rm -f "$temp_file"
            return 1
        fi
        http_code="200"  # wget doesn't easily provide HTTP status
        svg_content=$(cat "$temp_file")
    else
        log_error "Neither curl nor wget is available for downloading SVG content"
        return 1
    fi

    # Clean up temp file
    rm -f "$temp_file"

    # Check HTTP status code (only available with curl)
    if [[ "$http_code" != "200" ]] && [[ -n "$http_code" ]] && [[ "$http_code" != "000" ]]; then
        log_error "HTTP request failed with status code: $http_code"
        return 1
    fi

    # Validate SVG content more thoroughly
    if [[ -z "$svg_content" ]]; then
        log_error "Downloaded content is empty"
        return 1
    fi

    # Check for proper SVG structure
    if [[ ! "$svg_content" =~ \<svg[[:space:]] ]] && [[ ! "$svg_content" =~ ^\<\?xml.*\<svg ]]; then
        log_error "Downloaded content is not a valid SVG file"
        log_verbose "Content preview: ${svg_content:0:200}..."
        return 1
    fi

    # Check for shields.io error responses
    if [[ "$svg_content" =~ "404" ]] || [[ "$svg_content" =~ "error" ]] || [[ "$svg_content" =~ "not found" ]]; then
        log_error "Shields.io returned an error response"
        return 1
    fi

    log_verbose "SVG content downloaded and validated successfully"
    echo "$svg_content"
}

# Function to save output to file
save_to_file() {
    local content="$1"
    local file_path="$2"

    # Attempt to write content to file with error handling
    if ! echo "$content" > "$file_path"; then
        log_error "Failed to write content to file: $file_path"
        return 1
    fi

    # Get full path (portable version of realpath)
    local full_path
    if command -v realpath >/dev/null 2>&1; then
        full_path=$(realpath "$file_path")
    else
        # Fallback for systems without realpath
        full_path=$(cd "$(dirname "$file_path")" && pwd)/$(basename "$file_path")
    fi

    # Verify file was created and has content
    if [[ ! -f "$file_path" ]]; then
        log_error "File was not created: $file_path"
        return 1
    fi

    if [[ ! -s "$file_path" ]]; then
        log_error "File was created but is empty: $file_path"
        return 1
    fi

    log_info "Badge saved to: $full_path"
    echo "$full_path"
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -m|--message)
                MESSAGE="$2"
                shift 2
                ;;
            -l|--label)
                LABEL="$2"
                shift 2
                ;;
            -c|--color)
                COLOR="$2"
                shift 2
                ;;
            --label-color)
                LABEL_COLOR="$2"
                shift 2
                ;;
            -s|--style)
                STYLE="$2"
                shift 2
                ;;
            --logo)
                LOGO="$2"
                shift 2
                ;;
            --logo-color)
                LOGO_COLOR="$2"
                shift 2
                ;;
            --logo-size)
                LOGO_SIZE="$2"
                shift 2
                ;;
            -o|--output-file)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -f|--output-format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --cache-seconds)
                CACHE_SECONDS="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    parse_arguments "$@"

    # Validate inputs
    if ! validate_inputs; then
        exit 1
    fi

    # Generate badge URL
    local badge_url
    badge_url=$(generate_badge_url)

    # Generate output in requested format
    local output_content
    output_content=$(generate_output_formats "$badge_url")

    # Save to file if requested
    if [[ -n "$OUTPUT_FILE" ]]; then
        save_to_file "$output_content" "$OUTPUT_FILE"
    else
        # Print to stdout if no output file specified
        echo "$output_content"
    fi

    log_info "Badge generation completed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
